USE [master]
GO
/****** Object:  Database [BWC]    Script Date: 7/17/2018 11:46:44 PM ******/
CREATE DATABASE [BWC] ON  PRIMARY 
( NAME = N'BWC', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.EN2008R2\MSSQL\DATA\BWC.mdf' , SIZE = 6144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BWC_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.EN2008R2\MSSQL\DATA\BWC_log.ldf' , SIZE = 18240KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
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
/****** Object:  UserDefinedFunction [dbo].[fn_AuthenticateUser]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[ToDateTime]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ToDateTime] ( @Ticks bigint )
  RETURNS datetime2
AS
BEGIN
    DECLARE @DateTime datetime2 = '00010101';
    SET @DateTime = DATEADD( DAY, @Ticks / 864000000000, @DateTime );
    SET @DateTime = DATEADD( SECOND, ( @Ticks % 864000000000) / 10000000, @DateTime );
    RETURN DATEADD( NANOSECOND, ( @Ticks % 10000000 ) * 100, @DateTime );
END
GO
/****** Object:  UserDefinedFunction [dbo].[ToTicks]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ToTicks] ( @DateTime datetime )
  RETURNS bigint
AS
BEGIN
    DECLARE @Days bigint = DATEDIFF( DAY, '00010101', cast( @DateTime as date ) );
    DECLARE @Seconds bigint = DATEDIFF( SECOND, '00:00', cast( @DateTime as time( 7 ) ) );
    DECLARE @Nanoseconds bigint = DATEPART( NANOSECOND, @DateTime );
    RETURN  @Days * 864000000000 + @Seconds * 10000000 + @Nanoseconds / 100;
END
GO
/****** Object:  Table [dbo].[Category]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[Color]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[Component]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	[PurchasePrice] [decimal](18, 2) NULL,
	[Color] [nvarchar](250) NULL,
	[Unit] [nvarchar](250) NULL,
	[Description] [nvarchar](max) NULL,
	[Discount] [decimal](18, 2) NULL,
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
/****** Object:  Table [dbo].[Customer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
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
	[Discount] [decimal](18, 2) NULL,
	[ABN] [nvarchar](250) NULL,
	[IsBWC] [bigint] NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Material]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Material](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MaterialCode] [nvarchar](500) NULL,
	[MaterialName] [nvarchar](500) NULL,
	[Color] [nvarchar](250) NULL,
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
/****** Object:  Table [dbo].[Order]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	[DeliveryNo] [nvarchar](250) NULL,
	[Notes] [nvarchar](max) NULL,
	[SupplierId] [int] NULL,
	[SupplierName] [nvarchar](250) NULL,
	[SupplierAddress] [nvarchar](500) NULL,
	[SupplierEmail] [nvarchar](250) NULL,
	[SupplierPhone] [nvarchar](50) NULL,
	[CustomerId] [int] NULL,
	[CustomerName] [nvarchar](250) NULL,
	[CustomerAddress] [nvarchar](500) NULL,
	[CustomerEmail] [nvarchar](250) NULL,
	[CustomerPhone] [nvarchar](50) NULL,
	[OrderRefNo] [nvarchar](250) NULL,
	[OrderType] [int] NULL,
	[AMTExcGST] [decimal](18, 2) NULL,
	[GST] [decimal](18, 2) NULL,
	[AMTIncGST] [decimal](18, 2) NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[TotalReceived] [decimal](18, 2) NULL,
	[TotalPaid] [decimal](18, 2) NULL,
	[Balance] [decimal](18, 2) NULL,
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
/****** Object:  Table [dbo].[OrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderComponent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [bigint] NOT NULL,
	[ComponentId] [int] NOT NULL,
	[ColorId] [int] NULL,
	[ColorName] [nvarchar](250) NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[ExtCharge] [bit] NULL,
	[UnitId] [int] NULL,
	[UnitName] [nvarchar](250) NULL,
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
	[Discount] [decimal](18, 2) NULL,
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
/****** Object:  Table [dbo].[OrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	[AMTExcGST] [decimal](18, 2) NULL,
	[GST] [decimal](18, 2) NULL,
	[AMTIncGST] [decimal](18, 2) NULL,
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
/****** Object:  Table [dbo].[OrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[OrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	[ColorName] [nvarchar](250) NULL,
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
/****** Object:  Table [dbo].[Product]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[ProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[ProductMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[ProductPrice]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductPrice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupId] [bigint] NULL,
	[ProductMaterialId] [int] NOT NULL,
	[Row] [int] NOT NULL,
	[Column] [int] NOT NULL,
	[Value] [decimal](18, 2) NULL,
	[IsActive] [bit] NULL,
	[PriceType] [int] NULL,
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
/****** Object:  Table [dbo].[SEC_User]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  Table [dbo].[Supplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	[ABN] [nvarchar](250) NULL,
	[IsBWC] [bigint] NULL,
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

INSERT [dbo].[Component] ([Id], [ComponentCode], [ComponentName], [SupplierId], [Price], [PurchasePrice], [Color], [Unit], [Description], [Discount], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'BWC0002', N'Chain holder', 4, CAST(2000.00 AS Decimal(18, 2)), CAST(1800.00 AS Decimal(18, 2)), N'Brown Satin
', N'Each', N'Chain holder', CAST(10.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-12T23:11:36.510' AS DateTime), CAST(N'2018-07-14T22:18:30.913' AS DateTime))
INSERT [dbo].[Component] ([Id], [ComponentCode], [ComponentName], [SupplierId], [Price], [PurchasePrice], [Color], [Unit], [Description], [Discount], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'BWC0004', N'Double bracket ', 6, CAST(120.00 AS Decimal(18, 2)), CAST(110.00 AS Decimal(18, 2)), N'Brown Satin
', N'Each', N'double bracket then no need supply single bracket', CAST(7.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-16T17:55:29.103' AS DateTime), CAST(N'2018-07-14T22:18:23.993' AS DateTime))
INSERT [dbo].[Component] ([Id], [ComponentCode], [ComponentName], [SupplierId], [Price], [PurchasePrice], [Color], [Unit], [Description], [Discount], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'BWC0003', N'BWC0003 BWC0003', 4, CAST(200.00 AS Decimal(18, 2)), CAST(180.00 AS Decimal(18, 2)), N'Brown Satin
', N'Each', N'BWC0003 BWC0003', CAST(5.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-07-05T18:22:28.283' AS DateTime), CAST(N'2018-07-14T22:18:16.453' AS DateTime))
SET IDENTITY_INSERT [dbo].[Component] OFF
SET IDENTITY_INSERT [dbo].[Customer] ON 

INSERT [dbo].[Customer] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [Discount], [ABN], [IsBWC], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'BWC', N'System', N'B WINDOW COVERS PTY LTD', N'bwindowcovers@gmail.com', NULL, N'http://bwindowcovers.com.au', NULL, N'1/52 SMITH RD, SPRINGVALE, VIC 3171', NULL, NULL, NULL, NULL, N'8502 7472', NULL, NULL, NULL, CAST(0.00 AS Decimal(18, 2)), N'A.B.N 34 205 612 818', 1, NULL, NULL, NULL, CAST(N'2018-07-09T21:12:47.537' AS DateTime), CAST(N'2018-07-17T23:18:16.893' AS DateTime))
INSERT [dbo].[Customer] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [Discount], [ABN], [IsBWC], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'Tung', N'Le', N'Aperia Solution', N'tungle@agmail.com', NULL, NULL, NULL, N'39b truong chinh, phuong 14, quan Tan Binh, HCM', NULL, NULL, NULL, NULL, N'0975436610', NULL, NULL, NULL, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-09T23:23:45.500' AS DateTime), CAST(N'2018-07-17T23:18:40.637' AS DateTime))
SET IDENTITY_INSERT [dbo].[Customer] OFF
SET IDENTITY_INSERT [dbo].[Material] ON 

INSERT [dbo].[Material] ([Id], [MaterialCode], [MaterialName], [Color], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'bwc23456', N'SHANN MESH', N'Blue', 4, NULL, N'VALESCO - WHOLESALE PRICE - GST NOT INC.', 1, NULL, NULL, CAST(N'2018-06-14T22:27:14.670' AS DateTime), CAST(N'2018-07-14T20:52:32.403' AS DateTime))
INSERT [dbo].[Material] ([Id], [MaterialCode], [MaterialName], [Color], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'bwdc345', N'SHAW -SCREEN (2500/3200MM)', N'white', 5, NULL, N'SHAW -SCREEN (2500/3200MM)', 1, NULL, NULL, CAST(N'2018-06-14T22:32:04.043' AS DateTime), CAST(N'2018-07-14T20:52:21.557' AS DateTime))
INSERT [dbo].[Material] ([Id], [MaterialCode], [MaterialName], [Color], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'bwc123', N'SHAW -  LE REVE B/O (3000MM) - MANTRA B/O (3000MM)', N'Yellow', 5, NULL, N'SHAW -  LE REVE B/O (3000MM) - MANTRA B/O (3000MM)', 1, NULL, NULL, CAST(N'2018-06-17T16:06:42.600' AS DateTime), CAST(N'2018-07-14T12:27:25.947' AS DateTime))
SET IDENTITY_INSERT [dbo].[Material] OFF
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529590581377, 2, NULL, 3, CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-22T00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, NULL, 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'123576787', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-21T21:16:49.643' AS DateTime), CAST(N'2018-06-27T23:28:40.180' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529590718053, 3, NULL, 3, CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-21T00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, NULL, 6, N'BWC Company', N'123 Syney Australia', N'tungle@aperia.com', N'123456', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-21T21:18:49.343' AS DateTime), CAST(N'2018-07-16T22:20:00.400' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529592217856, 1, NULL, 2, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-21T00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 5, N'CSC', N'quoturm', N'mngo@aperia.com', N'1234', NULL, NULL, NULL, NULL, NULL, N'123123', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-21T21:44:21.587' AS DateTime), CAST(N'2018-07-16T22:20:11.590' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529595111990, 2, N'Tuan Le', 4, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:47:17.000' AS DateTime), CAST(N'2018-04-24T00:00:00.000' AS DateTime), NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, CAST(8724.36 AS Decimal(18, 2)), CAST(4360.00 AS Decimal(18, 2)), CAST(567.00 AS Decimal(18, 2)), CAST(3793.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-21T22:32:37.280' AS DateTime), CAST(N'2018-06-25T21:18:07.170' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330251506, 2, N'Tuan Le', 3, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:44:15.003' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, CAST(2193.08 AS Decimal(18, 2)), CAST(2184.36 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.003' AS DateTime), CAST(N'2018-07-17T23:32:34.703' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330437904, 1, NULL, 1, CAST(5.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:47:17.000' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', NULL, NULL, NULL, NULL, NULL, N'123123', 1, NULL, NULL, NULL, CAST(8409.45 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:47:17.990' AS DateTime), CAST(N'2018-06-30T13:04:46.773' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330652517, 1, NULL, 2, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:50:52.600' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', NULL, NULL, NULL, NULL, NULL, N'123123', 1, NULL, NULL, NULL, CAST(9.72 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:50:52.600' AS DateTime), CAST(N'2018-07-17T21:08:45.797' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330861321, 1, NULL, 2, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:54:21.403' AS DateTime), NULL, NULL, CAST(N'2018-07-15T17:00:00.000' AS DateTime), N'123456', N'this is note', 5, N'CSC', N'quoturm', N'mngo@aperia.com', N'1234', NULL, NULL, NULL, NULL, NULL, N'123123', 1, NULL, NULL, NULL, CAST(9.72 AS Decimal(18, 2)), CAST(38.88 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:54:21.403' AS DateTime), CAST(N'2018-07-17T21:07:34.823' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330946656, 1, NULL, 6, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:55:46.000' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 5, N'CSC', N'quoturm', N'mngo@aperia.com', N'1234', NULL, NULL, NULL, NULL, NULL, N'123123', 1, NULL, NULL, NULL, CAST(9.72 AS Decimal(18, 2)), CAST(9.72 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:55:46.763' AS DateTime), CAST(N'2018-07-16T22:19:41.773' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530331633177, 2, N'Tuan Le', 6, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T11:07:13.000' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 4, N'aperia', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, CAST(9810.00 AS Decimal(18, 2)), CAST(9810.00 AS Decimal(18, 2)), CAST(900.00 AS Decimal(18, 2)), CAST(8910.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-30T11:07:13.270' AS DateTime), CAST(N'2018-07-16T22:19:32.147' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530360311814, 2, N'Tuan Le', 3, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T19:05:11.893' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 4, N'aperia', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, CAST(6540.00 AS Decimal(18, 2)), CAST(3270.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, CAST(N'2018-06-30T19:05:11.893' AS DateTime), CAST(N'2018-07-16T22:19:22.417' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530360334538, 2, N'Tuan Le', 4, CAST(7.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T19:05:34.000' AS DateTime), NULL, NULL, NULL, NULL, N'this is note', 4, N'aperia', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, N'12312412412', 1, NULL, NULL, NULL, CAST(3214.28 AS Decimal(18, 2)), CAST(3216.42 AS Decimal(18, 2)), CAST(932.28 AS Decimal(18, 2)), CAST(2284.14 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-30T19:05:34.593' AS DateTime), CAST(N'2018-07-16T22:19:00.100' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530787392102, 2, N'Tuan Le', 6, CAST(7.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(N'2018-07-05T17:43:12.000' AS DateTime), NULL, NULL, CAST(N'2018-07-13T17:00:00.000' AS DateTime), N'123', N'this is note', 4, N'aperia', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, NULL, NULL, NULL, NULL, N'2345', 1, CAST(2000.00 AS Decimal(18, 2)), CAST(140.00 AS Decimal(18, 2)), CAST(2140.00 AS Decimal(18, 2)), CAST(10914.00 AS Decimal(18, 2)), CAST(10914.00 AS Decimal(18, 2)), CAST(10700.00 AS Decimal(18, 2)), CAST(214.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-05T17:43:12.180' AS DateTime), CAST(N'2018-07-17T19:26:53.690' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1531149326056, NULL, NULL, 1, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-09T23:08:46.980' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, N'BWC', N'1234 truong chinh', N'tungle@gmail.com', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-09T22:15:49.453' AS DateTime), NULL, NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1531152513899, NULL, NULL, 5, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-09T23:08:46.980' AS DateTime), NULL, NULL, NULL, NULL, N'new order', NULL, NULL, NULL, NULL, NULL, 2, N'Aperia Solution', N'39b truong chinh, phuong 14, quan Tan Binh, HCM', N'tungle@gmail.com', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-09T23:08:46.980' AS DateTime), CAST(N'2018-07-10T22:12:12.707' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [DeliveryNo], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [CustomerId], [CustomerName], [CustomerAddress], [CustomerEmail], [CustomerPhone], [OrderRefNo], [OrderType], [AMTExcGST], [GST], [AMTIncGST], [TotalAmount], [TotalReceived], [TotalPaid], [Balance], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1531235364561, NULL, N'tung', 2, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-10T22:09:38.130' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, N'Aperia Solution', N'39b truong chinh, phuong 14, quan Tan Binh, HCM', N'tungle@agmail.com', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-10T22:09:38.130' AS DateTime), CAST(N'2018-07-10T22:12:33.757' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderComponent] ON 

INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (37, 1531152513899, 4, NULL, N'Brown Satin
', 2, CAST(120.00 AS Decimal(18, 2)), NULL, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(240.00 AS Numeric(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-10T20:13:52.803' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (38, 1531152513899, 5, NULL, N'Brown Satin
', 1, CAST(200.00 AS Decimal(18, 2)), NULL, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(200.00 AS Numeric(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-10T20:13:52.803' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (39, 1531235364561, 1, NULL, N'Brown Satin
', 3, CAST(2000.00 AS Decimal(18, 2)), 0, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(6000.00 AS Numeric(18, 2)), NULL, NULL, 3, NULL, NULL, NULL, NULL, CAST(N'2018-07-10T22:16:08.773' AS DateTime), CAST(N'2018-07-14T23:10:25.783' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (48, 1530787392102, 1, NULL, N'Brown Satin
', 2, CAST(1800.00 AS Decimal(18, 2)), 0, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(3240.00 AS Numeric(18, 2)), NULL, NULL, 2, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-14T22:32:44.243' AS DateTime), CAST(N'2018-07-14T22:43:43.900' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (49, 1530787392102, 5, NULL, N'Brown Satin
', 1, CAST(180.00 AS Decimal(18, 2)), 0, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(171.00 AS Numeric(18, 2)), NULL, NULL, 1, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-14T22:32:44.243' AS DateTime), CAST(N'2018-07-17T20:47:17.247' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (52, 1529590718053, 4, NULL, N'Brown Satin
', 1, CAST(110.00 AS Decimal(18, 2)), NULL, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(102.30 AS Numeric(18, 2)), NULL, NULL, NULL, CAST(7.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-16T20:06:23.997' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (53, 1530331633177, 1, NULL, N'Brown Satin
', 1, CAST(1800.00 AS Decimal(18, 2)), 0, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(1620.00 AS Numeric(18, 2)), NULL, NULL, 1, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-17T20:58:45.110' AS DateTime), CAST(N'2018-07-17T21:01:48.603' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [ColorName], [Quantity], [Price], [ExtCharge], [UnitId], [UnitName], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [Discount], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (54, 1530330251506, 1, NULL, N'Brown Satin
', 1, CAST(1800.00 AS Decimal(18, 2)), 0, NULL, N'Each', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(1620.00 AS Numeric(18, 2)), NULL, NULL, 1, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-17T23:31:09.660' AS DateTime), CAST(N'2018-07-17T23:32:42.647' AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderComponent] OFF
SET IDENTITY_INSERT [dbo].[OrderInvoice] ON 

INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [AMTExcGST], [GST], [AMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, N'34567', CAST(N'2018-06-27T22:29:46.097' AS DateTime), CAST(3456.00 AS Decimal(18, 2)), NULL, N'ko biet', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-27T22:29:46.097' AS DateTime), CAST(N'2018-06-27T23:05:35.820' AS DateTime))
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [AMTExcGST], [GST], [AMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1529595111990, N'123abc', CAST(N'2018-06-27T22:30:15.030' AS DateTime), CAST(345.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-27T22:30:15.030' AS DateTime), CAST(N'2018-06-27T22:57:46.193' AS DateTime))
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [AMTExcGST], [GST], [AMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529592217856, N'2143', CAST(N'2018-06-29T22:56:45.680' AS DateTime), CAST(500.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-29T22:56:45.680' AS DateTime), NULL)
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [AMTExcGST], [GST], [AMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, 1530360334538, N'123456', CAST(N'2018-07-03T00:18:20.177' AS DateTime), CAST(3456.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-07-03T00:18:20.177' AS DateTime), NULL)
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [AMTExcGST], [GST], [AMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, 1530787392102, N'bwc123', CAST(N'2018-07-14T10:47:59.557' AS DateTime), CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(2000.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(2100.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-14T10:47:59.557' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderInvoice] OFF
SET IDENTITY_INSERT [dbo].[OrderPayment] ON 

INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, CAST(N'2018-06-27T22:00:33.330' AS DateTime), N'Check', CAST(234.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-27T22:00:33.330' AS DateTime), CAST(N'2018-06-27T22:18:20.137' AS DateTime))
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529595111990, CAST(N'2018-06-27T22:29:26.327' AS DateTime), N'Credit Card', CAST(333.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-27T22:29:26.327' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, 1529592217856, CAST(N'2018-06-29T22:56:53.560' AS DateTime), N'Cash', CAST(300.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-29T22:56:53.560' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, 1530331633177, CAST(N'2018-06-30T18:18:26.123' AS DateTime), N'Check', CAST(900.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T18:18:26.123' AS DateTime), CAST(N'2018-07-15T15:32:20.870' AS DateTime))
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1530787392102, CAST(N'2018-07-06T23:53:54.043' AS DateTime), N'Cash', CAST(22.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-06T23:53:54.043' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (23, 1530360334538, CAST(N'2018-07-07T00:25:57.883' AS DateTime), N'Cash', CAST(210.28 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-07T00:25:57.883' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (28, 1530787392102, CAST(N'2018-07-07T16:17:27.663' AS DateTime), N'Cash', CAST(2000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-07T16:17:27.663' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (29, 1530360334538, CAST(N'2018-07-14T23:13:26.940' AS DateTime), N'Credit Card', CAST(300.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-14T23:13:26.940' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (30, 1530787392102, CAST(N'2018-07-17T19:22:31.640' AS DateTime), N'Cash', CAST(8678.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-17T19:22:31.640' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (31, 1530360334538, CAST(N'2018-07-17T19:22:31.640' AS DateTime), N'Cash', CAST(322.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-17T19:22:31.640' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (32, 1530360334538, CAST(N'2018-07-17T15:38:53.670' AS DateTime), N'Cash', CAST(100.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-17T22:39:13.520' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderPayment] OFF
SET IDENTITY_INSERT [dbo].[OrderProduct] ON 

INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, 1, 4, 1, 1, NULL, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), NULL, NULL, 1, 2, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T21:28:10.287' AS DateTime), CAST(N'2018-07-17T21:18:09.587' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1529595111990, 2, 4, 1, 1, NULL, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(2.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T22:26:06.050' AS DateTime), CAST(N'2018-06-25T22:37:35.543' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529592217856, 2, 2, 1, 1, N'NA', 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(200.00 AS Numeric(18, 2)), CAST(400.00 AS Numeric(18, 2)), NULL, NULL, 1, 1, NULL, 1, CAST(400.00 AS Decimal(18, 2)), CAST(32.00 AS Decimal(18, 2)), CAST(432.00 AS Decimal(18, 2)), CAST(200.00 AS Decimal(18, 2)), CAST(16.00 AS Decimal(18, 2)), CAST(216.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-27T23:33:58.537' AS DateTime), CAST(N'2018-07-15T15:30:10.050' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, 1529590581377, 2, 4, 1, 1, NULL, 1, 1, 1, 2, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(2000.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 0, CAST(4000.00 AS Decimal(18, 2)), CAST(400.00 AS Decimal(18, 2)), CAST(4400.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-29T22:46:37.260' AS DateTime), CAST(N'2018-07-16T20:06:42.243' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, 1530330251506, 1, 2, 1, 1, NULL, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), CAST(8.00 AS Numeric(18, 2)), NULL, NULL, 1, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.010' AS DateTime), CAST(N'2018-07-17T23:36:02.483' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, 1530330251506, 2, 4, 1, 1, NULL, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(2.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.010' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, 1530330437904, 2, 2, 1, 1, NULL, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:47:18.007' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, 1530330652517, 2, 2, 1, 1, NULL, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:50:52.620' AS DateTime), CAST(N'2018-07-17T21:08:38.437' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 1530330861321, 2, 2, 1, 1, NULL, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 12, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:54:21.417' AS DateTime), CAST(N'2018-07-17T21:07:42.357' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1530330946656, 2, 2, 1, 1, NULL, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 3, 3, NULL, 6, CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:55:46.777' AS DateTime), CAST(N'2018-07-17T21:06:13.827' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, 1530331633177, 2, 4, 1, 1, NULL, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(2000.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), NULL, NULL, 2, 1, NULL, 1, CAST(4000.00 AS Decimal(18, 2)), CAST(360.00 AS Decimal(18, 2)), CAST(4360.00 AS Decimal(18, 2)), CAST(2000.00 AS Decimal(18, 2)), CAST(180.00 AS Decimal(18, 2)), CAST(2180.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T11:07:13.273' AS DateTime), CAST(N'2018-07-17T21:05:30.787' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, 1530331633177, 1, 5, 1, 1, NULL, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 1, 1, NULL, 1, CAST(3000.00 AS Decimal(18, 2)), CAST(270.00 AS Decimal(18, 2)), CAST(3270.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T12:42:20.607' AS DateTime), CAST(N'2018-07-17T20:56:05.890' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (13, 1530330437904, 1, 5, 1, 1, NULL, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), NULL, NULL, 0, 0, NULL, 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T13:04:17.027' AS DateTime), CAST(N'2018-07-17T21:09:06.297' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (14, 1530360311814, 2, 4, 1, 1, NULL, 4, 1, 1, 2, 1, 4, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 1, -1, NULL, 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:11.897' AS DateTime), CAST(N'2018-07-17T21:06:34.130' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (15, 1530360311814, 1, 5, 1, 1, NULL, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 0, 1, NULL, 1, CAST(2.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:11.897' AS DateTime), CAST(N'2018-06-30T19:06:43.067' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (16, 1530360334538, 1, 5, 1, 6, NULL, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), N'123456', CAST(N'2018-06-28T17:00:00.000' AS DateTime), 1, 0, NULL, 1, CAST(3000.00 AS Decimal(18, 2)), CAST(210.00 AS Decimal(18, 2)), CAST(3210.00 AS Decimal(18, 2)), CAST(3000.00 AS Decimal(18, 2)), CAST(210.00 AS Decimal(18, 2)), CAST(3210.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:34.597' AS DateTime), CAST(N'2018-07-01T16:43:09.200' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (17, 1530360334538, 1, 2, 1, 4, NULL, 1, 1, 1, 2, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(2.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), N'123abc', CAST(N'2018-06-29T17:00:00.000' AS DateTime), 3, 1, NULL, 1, CAST(4.00 AS Decimal(18, 2)), CAST(0.28 AS Decimal(18, 2)), CAST(4.28 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)), CAST(0.14 AS Decimal(18, 2)), CAST(2.14 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T20:01:05.057' AS DateTime), CAST(N'2018-07-14T23:17:59.727' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (18, 1530787392102, 2, 4, 1, 4, N'white', 1, 1, 1, 2, 1, 10, CAST(0.00 AS Numeric(18, 2)), CAST(2000.00 AS Numeric(18, 2)), CAST(2000.00 AS Numeric(18, 2)), NULL, NULL, 1, 1, NULL, 1, CAST(2000.00 AS Decimal(18, 2)), CAST(140.00 AS Decimal(18, 2)), CAST(2140.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-05T17:43:12.183' AS DateTime), CAST(N'2018-07-14T22:43:29.177' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (19, 1530787392102, 1, 4, 1, 2, N'blue', 2, 4, 1, 2, 1, 5, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(3800.00 AS Numeric(18, 2)), NULL, NULL, 1, 0, NULL, 1, CAST(4000.00 AS Decimal(18, 2)), CAST(280.00 AS Decimal(18, 2)), CAST(4280.00 AS Decimal(18, 2)), CAST(4000.00 AS Decimal(18, 2)), CAST(280.00 AS Decimal(18, 2)), CAST(4280.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-05T23:32:38.397' AS DateTime), CAST(N'2018-07-17T22:05:02.927' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (24, 1531152513899, 2, 5, 1, 1, NULL, 1, 5, 1, 2, 2, NULL, CAST(0.00 AS Numeric(18, 2)), CAST(200.00 AS Numeric(18, 2)), CAST(400.00 AS Numeric(18, 2)), NULL, NULL, 1, 1, NULL, 1, CAST(400.00 AS Decimal(18, 2)), CAST(40.00 AS Decimal(18, 2)), CAST(440.00 AS Decimal(18, 2)), CAST(200.00 AS Decimal(18, 2)), CAST(20.00 AS Decimal(18, 2)), CAST(220.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-10T21:21:50.820' AS DateTime), CAST(N'2018-07-10T21:34:43.063' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ColorName], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (25, 1531235364561, 1, 5, 1, 1, NULL, 1, 1, 2, 3, 2, 5, CAST(2000.00 AS Numeric(18, 2)), CAST(2000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), NULL, NULL, 2, 2, NULL, 1, CAST(8000.00 AS Decimal(18, 2)), CAST(800.00 AS Decimal(18, 2)), CAST(8800.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-07-10T22:15:27.123' AS DateTime), CAST(N'2018-07-14T23:10:20.177' AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderProduct] OFF
SET IDENTITY_INSERT [dbo].[Product] ON 

INSERT [dbo].[Product] ([Id], [ProductCode], [ProductName], [CategoryId], [Notes], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'BWCP00001', N'ROLLER BLIND - BWC', 2, N'ROLLER BLIND - Produce by BWC
ROLLER BLIND - Produce by BWC
ROLLER BLIND - Produce by BWC
ROLLER BLIND - Produce by BWC
ROLLER BLIND - Produce by BWC', 1, NULL, NULL, CAST(N'2018-06-14T23:12:21.447' AS DateTime), CAST(N'2018-07-14T18:21:05.560' AS DateTime))
INSERT [dbo].[Product] ([Id], [ProductCode], [ProductName], [CategoryId], [Notes], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'ACMEDA00002', N'ROLLER BLIND - ACMEDA', 1, N'ROLLER BLIND - Product by ACMEDA', 1, NULL, NULL, CAST(N'2018-06-18T22:58:59.757' AS DateTime), CAST(N'2018-07-13T22:00:14.727' AS DateTime))
SET IDENTITY_INSERT [dbo].[Product] OFF
SET IDENTITY_INSERT [dbo].[ProductComponent] ON 

INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1, 4, 3, 2, CAST(5000.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-16T17:57:38.873' AS DateTime), CAST(N'2018-06-17T22:26:29.660' AS DateTime))
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 1, 1, 1, 1, CAST(2222.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-16T20:13:26.663' AS DateTime), CAST(N'2018-07-14T21:45:15.963' AS DateTime))
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
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1, 5, NULL, NULL, CAST(N'2018-06-25T17:37:17.557' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, 2, 5, NULL, NULL, CAST(N'2018-06-30T23:52:09.460' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, 2, 4, NULL, NULL, CAST(N'2018-07-01T23:46:13.853' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[ProductMaterial] OFF
SET IDENTITY_INSERT [dbo].[ProductPrice] ON 

INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (144, 636660593002370000, 3, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (145, 636660593002370000, 3, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (146, 636660593002370000, 3, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (147, 636660593002370000, 3, 4, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (148, 636660593002370000, 3, 5, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (149, 636660593002370000, 3, 6, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (150, 636660593002370000, 3, 7, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (151, 636660593002370000, 3, 8, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (152, 636660593002370000, 3, 9, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (153, 636660593002370000, 3, 10, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (154, 636660593002370000, 3, 11, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (155, 636660593002370000, 3, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (156, 636660593002370000, 3, 2, 2, CAST(30000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (157, 636660593002370000, 3, 3, 2, CAST(40000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (158, 636660593002370000, 3, 4, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (159, 636660593002370000, 3, 5, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (160, 636660593002370000, 3, 6, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (161, 636660593002370000, 3, 7, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (162, 636660593002370000, 3, 8, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (163, 636660593002370000, 3, 9, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (164, 636660593002370000, 3, 10, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (165, 636660593002370000, 3, 11, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (166, 636660593002370000, 3, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (167, 636660593002370000, 3, 2, 3, CAST(40000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (168, 636660593002370000, 3, 3, 3, CAST(50000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (169, 636660593002370000, 3, 4, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (170, 636660593002370000, 3, 5, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (171, 636660593002370000, 3, 6, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (172, 636660593002370000, 3, 7, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (173, 636660593002370000, 3, 8, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (174, 636660593002370000, 3, 9, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (175, 636660593002370000, 3, 10, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (176, 636660593002370000, 3, 11, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (177, 636660593002370000, 3, 1, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (178, 636660593002370000, 3, 2, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (179, 636660593002370000, 3, 3, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (180, 636660593002370000, 3, 4, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (181, 636660593002370000, 3, 5, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (182, 636660593002370000, 3, 6, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (183, 636660593002370000, 3, 7, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (184, 636660593002370000, 3, 8, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (185, 636660593002370000, 3, 9, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (186, 636660593002370000, 3, 10, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (187, 636660593002370000, 3, 11, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (188, 636660593002370000, 3, 1, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (189, 636660593002370000, 3, 2, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (190, 636660593002370000, 3, 3, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (191, 636660593002370000, 3, 4, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (192, 636660593002370000, 3, 5, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (193, 636660593002370000, 3, 6, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (194, 636660593002370000, 3, 7, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (195, 636660593002370000, 3, 8, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (196, 636660593002370000, 3, 9, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (197, 636660593002370000, 3, 10, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (198, 636660593002370000, 3, 11, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (199, 636660593002370000, 3, 1, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (200, 636660593002370000, 3, 2, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (201, 636660593002370000, 3, 3, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (202, 636660593002370000, 3, 4, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (203, 636660593002370000, 3, 5, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (204, 636660593002370000, 3, 6, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (205, 636660593002370000, 3, 7, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (206, 636660593002370000, 3, 8, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (207, 636660593002370000, 3, 9, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (208, 636660593002370000, 3, 10, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (209, 636660593002370000, 3, 11, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (210, 636660593002370000, 3, 1, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (211, 636660593002370000, 3, 2, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (212, 636660593002370000, 3, 3, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (213, 636660593002370000, 3, 4, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (214, 636660593002370000, 3, 5, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (215, 636660593002370000, 3, 6, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (216, 636660593002370000, 3, 7, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (217, 636660593002370000, 3, 8, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (218, 636660593002370000, 3, 9, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (219, 636660593002370000, 3, 10, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (220, 636660593002370000, 3, 11, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (221, 636660593002370000, 3, 1, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (222, 636660593002370000, 3, 2, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (223, 636660593002370000, 3, 3, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (224, 636660593002370000, 3, 4, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (225, 636660593002370000, 3, 5, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (226, 636660593002370000, 3, 6, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (227, 636660593002370000, 3, 7, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (228, 636660593002370000, 3, 8, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (229, 636660593002370000, 3, 9, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (230, 636660593002370000, 3, 10, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (231, 636660593002370000, 3, 11, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:28:20.237' AS DateTime), CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (297, 636648711539530000, 5, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (298, 636648711539530000, 5, 2, 1, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (299, 636648711539530000, 5, 3, 1, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (300, 636648711539530000, 5, 4, 1, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (301, 636648711539530000, 5, 5, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (302, 636648711539530000, 5, 1, 2, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (303, 636648711539530000, 5, 2, 2, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (304, 636648711539530000, 5, 3, 2, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (305, 636648711539530000, 5, 4, 2, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (306, 636648711539530000, 5, 5, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (307, 636648711539530000, 5, 1, 3, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (308, 636648711539530000, 5, 2, 3, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (309, 636648711539530000, 5, 3, 3, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (310, 636648711539530000, 5, 4, 3, CAST(5.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (311, 636648711539530000, 5, 5, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (312, 636648711539530000, 5, 1, 4, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (313, 636648711539530000, 5, 2, 4, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (314, 636648711539530000, 5, 3, 4, CAST(5.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (315, 636648711539530000, 5, 4, 4, CAST(6.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (316, 636648711539530000, 5, 5, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (317, 636648711539530000, 5, 1, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (318, 636648711539530000, 5, 2, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (319, 636648711539530000, 5, 3, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (320, 636648711539530000, 5, 4, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (321, 636648711539530000, 5, 5, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (462, 636655396072530000, 7, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (463, 636655396072530000, 7, 2, 1, CAST(40.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (464, 636655396072530000, 7, 3, 1, CAST(50.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (465, 636655396072530000, 7, 4, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (466, 636655396072530000, 7, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (467, 636655396072530000, 7, 1, 2, CAST(40.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (468, 636655396072530000, 7, 2, 2, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (469, 636655396072530000, 7, 3, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (470, 636655396072530000, 7, 4, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (471, 636655396072530000, 7, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (472, 636655396072530000, 7, 1, 3, CAST(50.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (473, 636655396072530000, 7, 2, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (474, 636655396072530000, 7, 3, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (475, 636655396072530000, 7, 4, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (476, 636655396072530000, 7, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (477, 636655396072530000, 7, 1, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (478, 636655396072530000, 7, 2, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (479, 636655396072530000, 7, 3, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (480, 636655396072530000, 7, 4, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (481, 636655396072530000, 7, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (482, 636655396072530000, 7, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (483, 636655396072530000, 7, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (484, 636655396072530000, 7, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (485, 636655396072530000, 7, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (486, 636655396072530000, 7, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (559, 636655461680130000, 6, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (560, 636655461680130000, 6, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (561, 636655461680130000, 6, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (562, 636655461680130000, 6, 4, 1, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (563, 636655461680130000, 6, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (564, 636655461680130000, 6, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (565, 636655461680130000, 6, 2, 2, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (566, 636655461680130000, 6, 3, 2, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (567, 636655461680130000, 6, 4, 2, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (568, 636655461680130000, 6, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (569, 636655461680130000, 6, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (570, 636655461680130000, 6, 2, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (571, 636655461680130000, 6, 3, 3, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (572, 636655461680130000, 6, 4, 3, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (573, 636655461680130000, 6, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (574, 636655461680130000, 6, 1, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (575, 636655461680130000, 6, 2, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (576, 636655461680130000, 6, 3, 4, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (577, 636655461680130000, 6, 4, 4, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (578, 636655461680130000, 6, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (579, 636655461680130000, 6, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (580, 636655461680130000, 6, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (581, 636655461680130000, 6, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (582, 636655461680130000, 6, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (583, 636655461680130000, 6, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (609, 636655488361200000, 10, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (610, 636655488361200000, 10, 2, 1, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (611, 636655488361200000, 10, 3, 1, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (612, 636655488361200000, 10, 4, 1, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (613, 636655488361200000, 10, 5, 1, CAST(5.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (614, 636655488361200000, 10, 1, 2, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (615, 636655488361200000, 10, 2, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (616, 636655488361200000, 10, 3, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (617, 636655488361200000, 10, 4, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (618, 636655488361200000, 10, 5, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (619, 636655488361200000, 10, 1, 3, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (620, 636655488361200000, 10, 2, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (621, 636655488361200000, 10, 3, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (622, 636655488361200000, 10, 4, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (623, 636655488361200000, 10, 5, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (624, 636655488361200000, 10, 1, 4, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (625, 636655488361200000, 10, 2, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (626, 636655488361200000, 10, 3, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (627, 636655488361200000, 10, 4, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (628, 636655488361200000, 10, 5, 4, CAST(8000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (629, 636655488361200000, 10, 1, 5, CAST(5.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (630, 636655488361200000, 10, 2, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (631, 636655488361200000, 10, 3, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (632, 636655488361200000, 10, 4, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (633, 636655488361200000, 10, 5, 5, CAST(9000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (855, 636660012533130000, 11, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (856, 636660012533130000, 11, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (857, 636660012533130000, 11, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (858, 636660012533130000, 11, 4, 1, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (859, 636660012533130000, 11, 5, 1, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (860, 636660012533130000, 11, 6, 1, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (861, 636660012533130000, 11, 7, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (862, 636660012533130000, 11, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (863, 636660012533130000, 11, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (864, 636660012533130000, 11, 3, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (865, 636660012533130000, 11, 4, 2, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (866, 636660012533130000, 11, 5, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (867, 636660012533130000, 11, 6, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (868, 636660012533130000, 11, 7, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (869, 636660012533130000, 11, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (870, 636660012533130000, 11, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (871, 636660012533130000, 11, 3, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (872, 636660012533130000, 11, 4, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (873, 636660012533130000, 11, 5, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (874, 636660012533130000, 11, 6, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (875, 636660012533130000, 11, 7, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (876, 636660012533130000, 11, 1, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (877, 636660012533130000, 11, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (878, 636660012533130000, 11, 3, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (879, 636660012533130000, 11, 4, 4, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (880, 636660012533130000, 11, 5, 4, CAST(8000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (881, 636660012533130000, 11, 6, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (882, 636660012533130000, 11, 7, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (883, 636660012533130000, 11, 1, 5, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (884, 636660012533130000, 11, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (885, 636660012533130000, 11, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (886, 636660012533130000, 11, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (887, 636660012533130000, 11, 5, 5, CAST(9000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (888, 636660012533130000, 11, 6, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (889, 636660012533130000, 11, 7, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (890, 636660012533130000, 11, 1, 6, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (891, 636660012533130000, 11, 2, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (892, 636660012533130000, 11, 3, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (893, 636660012533130000, 11, 4, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (894, 636660012533130000, 11, 5, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (895, 636660012533130000, 11, 6, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (896, 636660012533130000, 11, 7, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (897, 636660012533130000, 11, 1, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (898, 636660012533130000, 11, 2, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (899, 636660012533130000, 11, 3, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (900, 636660012533130000, 11, 4, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (901, 636660012533130000, 11, 5, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (902, 636660012533130000, 11, 6, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (903, 636660012533130000, 11, 7, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (904, 636660012533130000, 11, 1, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (905, 636660012533130000, 11, 2, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (906, 636660012533130000, 11, 3, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (907, 636660012533130000, 11, 4, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (908, 636660012533130000, 11, 5, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (909, 636660012533130000, 11, 6, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (910, 636660012533130000, 11, 7, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (911, 636660012533130000, 11, 1, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (912, 636660012533130000, 11, 2, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (913, 636660012533130000, 11, 3, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (914, 636660012533130000, 11, 4, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (915, 636660012533130000, 11, 5, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (916, 636660012533130000, 11, 6, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (917, 636660012533130000, 11, 7, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (918, 636660012533130000, 11, 1, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (919, 636660012533130000, 11, 2, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (920, 636660012533130000, 11, 3, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (921, 636660012533130000, 11, 4, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (922, 636660012533130000, 11, 5, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (923, 636660012533130000, 11, 6, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (924, 636660012533130000, 11, 7, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (925, 636660012533130000, 11, 1, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (926, 636660012533130000, 11, 2, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (927, 636660012533130000, 11, 3, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (928, 636660012533130000, 11, 4, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (929, 636660012533130000, 11, 5, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (930, 636660012533130000, 11, 6, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (931, 636660012533130000, 11, 7, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (932, 636660012533130000, 11, 1, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (933, 636660012533130000, 11, 2, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (934, 636660012533130000, 11, 3, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (935, 636660012533130000, 11, 4, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (936, 636660012533130000, 11, 5, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (937, 636660012533130000, 11, 6, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (938, 636660012533130000, 11, 7, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (939, 636660012533130000, 11, 1, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (940, 636660012533130000, 11, 2, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (941, 636660012533130000, 11, 3, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (942, 636660012533130000, 11, 4, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (943, 636660012533130000, 11, 5, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (944, 636660012533130000, 11, 6, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (945, 636660012533130000, 11, 7, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (946, 636660012533130000, 11, 1, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (947, 636660012533130000, 11, 2, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (948, 636660012533130000, 11, 3, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (949, 636660012533130000, 11, 4, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (950, 636660012533130000, 11, 5, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (951, 636660012533130000, 11, 6, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (952, 636660012533130000, 11, 7, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (953, 636660012533130000, 11, 1, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (954, 636660012533130000, 11, 2, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (955, 636660012533130000, 11, 3, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (956, 636660012533130000, 11, 4, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (957, 636660012533130000, 11, 5, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (958, 636660012533130000, 11, 6, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (959, 636660012533130000, 11, 7, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (960, 636660012533130000, 11, 1, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (961, 636660012533130000, 11, 2, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (962, 636660012533130000, 11, 3, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (963, 636660012533130000, 11, 4, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (964, 636660012533130000, 11, 5, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (965, 636660012533130000, 11, 6, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (966, 636660012533130000, 11, 7, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (967, 636660012533130000, 11, 1, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (968, 636660012533130000, 11, 2, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (969, 636660012533130000, 11, 3, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (970, 636660012533130000, 11, 4, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (971, 636660012533130000, 11, 5, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (972, 636660012533130000, 11, 6, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (973, 636660012533130000, 11, 7, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (974, 636660012533130000, 11, 1, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (975, 636660012533130000, 11, 2, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (976, 636660012533130000, 11, 3, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (977, 636660012533130000, 11, 4, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (978, 636660012533130000, 11, 5, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (979, 636660012533130000, 11, 6, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (980, 636660012533130000, 11, 7, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (981, 636660012533130000, 11, 8, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (982, 636660012533130000, 11, 8, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (983, 636660012533130000, 11, 8, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (984, 636660012533130000, 11, 8, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (985, 636660012533130000, 11, 8, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (986, 636660012533130000, 11, 8, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (987, 636660012533130000, 11, 8, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (988, 636660012533130000, 11, 8, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (989, 636660012533130000, 11, 8, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (990, 636660012533130000, 11, 8, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (991, 636660012533130000, 11, 8, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (992, 636660012533130000, 11, 8, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (993, 636660012533130000, 11, 8, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (994, 636660012533130000, 11, 8, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (995, 636660012533130000, 11, 8, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (996, 636660012533130000, 11, 8, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (997, 636660012533130000, 11, 8, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (998, 636660012533130000, 11, 8, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (999, 636660012533130000, 11, 9, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1000, 636660012533130000, 11, 9, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1001, 636660012533130000, 11, 9, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1002, 636660012533130000, 11, 9, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1003, 636660012533130000, 11, 9, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1004, 636660012533130000, 11, 9, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1005, 636660012533130000, 11, 9, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1006, 636660012533130000, 11, 9, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1007, 636660012533130000, 11, 9, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1008, 636660012533130000, 11, 9, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1009, 636660012533130000, 11, 9, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1010, 636660012533130000, 11, 9, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1011, 636660012533130000, 11, 9, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1012, 636660012533130000, 11, 9, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1013, 636660012533130000, 11, 9, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1014, 636660012533130000, 11, 9, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1015, 636660012533130000, 11, 9, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1016, 636660012533130000, 11, 9, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1017, 636660012533130000, 11, 10, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1018, 636660012533130000, 11, 10, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1019, 636660012533130000, 11, 10, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1020, 636660012533130000, 11, 10, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1021, 636660012533130000, 11, 10, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1022, 636660012533130000, 11, 10, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1023, 636660012533130000, 11, 10, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1024, 636660012533130000, 11, 10, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1025, 636660012533130000, 11, 10, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1026, 636660012533130000, 11, 10, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1027, 636660012533130000, 11, 10, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1028, 636660012533130000, 11, 10, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1029, 636660012533130000, 11, 10, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1030, 636660012533130000, 11, 10, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1031, 636660012533130000, 11, 10, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1032, 636660012533130000, 11, 10, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1033, 636660012533130000, 11, 10, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1034, 636660012533130000, 11, 10, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1035, 636660012533130000, 11, 11, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1036, 636660012533130000, 11, 11, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1037, 636660012533130000, 11, 11, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1038, 636660012533130000, 11, 11, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1039, 636660012533130000, 11, 11, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1040, 636660012533130000, 11, 11, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1041, 636660012533130000, 11, 11, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1042, 636660012533130000, 11, 11, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1043, 636660012533130000, 11, 11, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1044, 636660012533130000, 11, 11, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1045, 636660012533130000, 11, 11, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1046, 636660012533130000, 11, 11, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1047, 636660012533130000, 11, 11, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1048, 636660012533130000, 11, 11, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1049, 636660012533130000, 11, 11, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1050, 636660012533130000, 11, 11, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1051, 636660012533130000, 11, 11, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1052, 636660012533130000, 11, 11, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1053, 636660012533130000, 11, 12, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1054, 636660012533130000, 11, 12, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1055, 636660012533130000, 11, 12, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1056, 636660012533130000, 11, 12, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1057, 636660012533130000, 11, 12, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1058, 636660012533130000, 11, 12, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1059, 636660012533130000, 11, 12, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1060, 636660012533130000, 11, 12, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1061, 636660012533130000, 11, 12, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1062, 636660012533130000, 11, 12, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1063, 636660012533130000, 11, 12, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1064, 636660012533130000, 11, 12, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1065, 636660012533130000, 11, 12, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1066, 636660012533130000, 11, 12, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1067, 636660012533130000, 11, 12, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1068, 636660012533130000, 11, 12, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1069, 636660012533130000, 11, 12, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1070, 636660012533130000, 11, 12, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1071, 636660012533130000, 11, 13, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1072, 636660012533130000, 11, 13, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1073, 636660012533130000, 11, 13, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1074, 636660012533130000, 11, 13, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1075, 636660012533130000, 11, 13, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1076, 636660012533130000, 11, 13, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1077, 636660012533130000, 11, 13, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1078, 636660012533130000, 11, 13, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1079, 636660012533130000, 11, 13, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1080, 636660012533130000, 11, 13, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1081, 636660012533130000, 11, 13, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1082, 636660012533130000, 11, 13, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1083, 636660012533130000, 11, 13, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1084, 636660012533130000, 11, 13, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1085, 636660012533130000, 11, 13, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1086, 636660012533130000, 11, 13, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1087, 636660012533130000, 11, 13, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1088, 636660012533130000, 11, 13, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1089, 636660012533130000, 11, 14, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1090, 636660012533130000, 11, 14, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1091, 636660012533130000, 11, 14, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1092, 636660012533130000, 11, 14, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1093, 636660012533130000, 11, 14, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1094, 636660012533130000, 11, 14, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1095, 636660012533130000, 11, 14, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1096, 636660012533130000, 11, 14, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1097, 636660012533130000, 11, 14, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1098, 636660012533130000, 11, 14, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1099, 636660012533130000, 11, 14, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1100, 636660012533130000, 11, 14, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1101, 636660012533130000, 11, 14, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1102, 636660012533130000, 11, 14, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1103, 636660012533130000, 11, 14, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1104, 636660012533130000, 11, 14, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1105, 636660012533130000, 11, 14, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1106, 636660012533130000, 11, 14, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1107, 636660012533130000, 11, 15, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1108, 636660012533130000, 11, 15, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1109, 636660012533130000, 11, 15, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1110, 636660012533130000, 11, 15, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1111, 636660012533130000, 11, 15, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1112, 636660012533130000, 11, 15, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1113, 636660012533130000, 11, 15, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1114, 636660012533130000, 11, 15, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1115, 636660012533130000, 11, 15, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1116, 636660012533130000, 11, 15, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1117, 636660012533130000, 11, 15, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1118, 636660012533130000, 11, 15, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1119, 636660012533130000, 11, 15, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1120, 636660012533130000, 11, 15, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1121, 636660012533130000, 11, 15, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1122, 636660012533130000, 11, 15, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1123, 636660012533130000, 11, 15, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1124, 636660012533130000, 11, 15, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1125, 636660012533130000, 11, 16, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1126, 636660012533130000, 11, 16, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1127, 636660012533130000, 11, 16, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1128, 636660012533130000, 11, 16, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1129, 636660012533130000, 11, 16, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1130, 636660012533130000, 11, 16, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1131, 636660012533130000, 11, 16, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1132, 636660012533130000, 11, 16, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1133, 636660012533130000, 11, 16, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1134, 636660012533130000, 11, 16, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1135, 636660012533130000, 11, 16, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1136, 636660012533130000, 11, 16, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1137, 636660012533130000, 11, 16, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1138, 636660012533130000, 11, 16, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1139, 636660012533130000, 11, 16, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1140, 636660012533130000, 11, 16, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1141, 636660012533130000, 11, 16, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1142, 636660012533130000, 11, 16, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1143, 636660012533130000, 11, 17, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1144, 636660012533130000, 11, 17, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1145, 636660012533130000, 11, 17, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1146, 636660012533130000, 11, 17, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1147, 636660012533130000, 11, 17, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1148, 636660012533130000, 11, 17, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1149, 636660012533130000, 11, 17, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1150, 636660012533130000, 11, 17, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1151, 636660012533130000, 11, 17, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1152, 636660012533130000, 11, 17, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1153, 636660012533130000, 11, 17, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1154, 636660012533130000, 11, 17, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1155, 636660012533130000, 11, 17, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1156, 636660012533130000, 11, 17, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1157, 636660012533130000, 11, 17, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1158, 636660012533130000, 11, 17, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1159, 636660012533130000, 11, 17, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1160, 636660012533130000, 11, 17, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1161, 636660012533130000, 11, 18, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1162, 636660012533130000, 11, 18, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1163, 636660012533130000, 11, 18, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1164, 636660012533130000, 11, 18, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1165, 636660012533130000, 11, 18, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1166, 636660012533130000, 11, 18, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1167, 636660012533130000, 11, 18, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1168, 636660012533130000, 11, 18, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1169, 636660012533130000, 11, 18, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1170, 636660012533130000, 11, 18, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1171, 636660012533130000, 11, 18, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1172, 636660012533130000, 11, 18, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1173, 636660012533130000, 11, 18, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1174, 636660012533130000, 11, 18, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1175, 636660012533130000, 11, 18, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1176, 636660012533130000, 11, 18, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1177, 636660012533130000, 11, 18, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1178, 636660012533130000, 11, 18, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1179, 636660012533130000, 11, 19, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1180, 636660012533130000, 11, 19, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1181, 636660012533130000, 11, 19, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1182, 636660012533130000, 11, 19, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1183, 636660012533130000, 11, 19, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1184, 636660012533130000, 11, 19, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1185, 636660012533130000, 11, 19, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1186, 636660012533130000, 11, 19, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1187, 636660012533130000, 11, 19, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1188, 636660012533130000, 11, 19, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1189, 636660012533130000, 11, 19, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1190, 636660012533130000, 11, 19, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1191, 636660012533130000, 11, 19, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1192, 636660012533130000, 11, 19, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1193, 636660012533130000, 11, 19, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1194, 636660012533130000, 11, 19, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1195, 636660012533130000, 11, 19, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1196, 636660012533130000, 11, 19, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1197, 636660012533130000, 11, 20, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1198, 636660012533130000, 11, 20, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1199, 636660012533130000, 11, 20, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1200, 636660012533130000, 11, 20, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1201, 636660012533130000, 11, 20, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1202, 636660012533130000, 11, 20, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1203, 636660012533130000, 11, 20, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1204, 636660012533130000, 11, 20, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1205, 636660012533130000, 11, 20, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1206, 636660012533130000, 11, 20, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1207, 636660012533130000, 11, 20, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1208, 636660012533130000, 11, 20, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1209, 636660012533130000, 11, 20, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1210, 636660012533130000, 11, 20, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1211, 636660012533130000, 11, 20, 15, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1212, 636660012533130000, 11, 20, 16, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1213, 636660012533130000, 11, 20, 17, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1214, 636660012533130000, 11, 20, 18, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1264, 636660585714200000, 7, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1265, 636660585714200000, 7, 2, 1, CAST(40.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1266, 636660585714200000, 7, 3, 1, CAST(50.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1267, 636660585714200000, 7, 4, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1268, 636660585714200000, 7, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1269, 636660585714200000, 7, 1, 2, CAST(40.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1270, 636660585714200000, 7, 2, 2, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1271, 636660585714200000, 7, 3, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1272, 636660585714200000, 7, 4, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1273, 636660585714200000, 7, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1274, 636660585714200000, 7, 1, 3, CAST(50.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1275, 636660585714200000, 7, 2, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1276, 636660585714200000, 7, 3, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1277, 636660585714200000, 7, 4, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1278, 636660585714200000, 7, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1279, 636660585714200000, 7, 1, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1280, 636660585714200000, 7, 2, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1281, 636660585714200000, 7, 3, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1282, 636660585714200000, 7, 4, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1283, 636660585714200000, 7, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1284, 636660585714200000, 7, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1285, 636660585714200000, 7, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1286, 636660585714200000, 7, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1287, 636660585714200000, 7, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1288, 636660585714200000, 7, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T16:16:11.420' AS DateTime), CAST(N'2018-07-01T16:16:11.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1314, 636660854994870000, 6, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1315, 636660854994870000, 6, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1316, 636660854994870000, 6, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1317, 636660854994870000, 6, 4, 1, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1318, 636660854994870000, 6, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1319, 636660854994870000, 6, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1320, 636660854994870000, 6, 2, 2, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1321, 636660854994870000, 6, 3, 2, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1322, 636660854994870000, 6, 4, 2, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1323, 636660854994870000, 6, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1324, 636660854994870000, 6, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1325, 636660854994870000, 6, 2, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1326, 636660854994870000, 6, 3, 3, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1327, 636660854994870000, 6, 4, 3, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1328, 636660854994870000, 6, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1329, 636660854994870000, 6, 1, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1330, 636660854994870000, 6, 2, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1331, 636660854994870000, 6, 3, 4, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1332, 636660854994870000, 6, 4, 4, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1333, 636660854994870000, 6, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1334, 636660854994870000, 6, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1335, 636660854994870000, 6, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1336, 636660854994870000, 6, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1337, 636660854994870000, 6, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1338, 636660854994870000, 6, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:44:59.487' AS DateTime), CAST(N'2018-07-01T23:44:59.487' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1339, 636660855031330000, 6, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1340, 636660855031330000, 6, 2, 1, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1341, 636660855031330000, 6, 3, 1, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1342, 636660855031330000, 6, 4, 1, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1343, 636660855031330000, 6, 5, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1344, 636660855031330000, 6, 1, 2, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1345, 636660855031330000, 6, 2, 2, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1346, 636660855031330000, 6, 3, 2, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1347, 636660855031330000, 6, 4, 2, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1348, 636660855031330000, 6, 5, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1349, 636660855031330000, 6, 1, 3, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1350, 636660855031330000, 6, 2, 3, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1351, 636660855031330000, 6, 3, 3, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1352, 636660855031330000, 6, 4, 3, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1353, 636660855031330000, 6, 5, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1354, 636660855031330000, 6, 1, 4, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1355, 636660855031330000, 6, 2, 4, CAST(3.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1356, 636660855031330000, 6, 3, 4, CAST(4.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1357, 636660855031330000, 6, 4, 4, CAST(5.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1358, 636660855031330000, 6, 5, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1359, 636660855031330000, 6, 1, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1360, 636660855031330000, 6, 2, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1361, 636660855031330000, 6, 3, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1362, 636660855031330000, 6, 4, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1363, 636660855031330000, 6, 5, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T23:45:03.133' AS DateTime), CAST(N'2018-07-01T23:45:03.133' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1774, 636665757739570000, 9, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1775, 636665757739570000, 9, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1776, 636665757739570000, 9, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1777, 636665757739570000, 9, 4, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1778, 636665757739570000, 9, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1779, 636665757739570000, 9, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1780, 636665757739570000, 9, 2, 2, CAST(200.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1781, 636665757739570000, 9, 3, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1782, 636665757739570000, 9, 4, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1783, 636665757739570000, 9, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1784, 636665757739570000, 9, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1785, 636665757739570000, 9, 2, 3, CAST(300.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1786, 636665757739570000, 9, 3, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1787, 636665757739570000, 9, 4, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1788, 636665757739570000, 9, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1789, 636665757739570000, 9, 1, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1790, 636665757739570000, 9, 2, 4, CAST(400.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1791, 636665757739570000, 9, 3, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1792, 636665757739570000, 9, 4, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1793, 636665757739570000, 9, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1794, 636665757739570000, 9, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1795, 636665757739570000, 9, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1796, 636665757739570000, 9, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1797, 636665757739570000, 9, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1798, 636665757739570000, 9, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T15:58:18.400' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1799, 636665758639430000, 9, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1800, 636665758639430000, 9, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1801, 636665758639430000, 9, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1802, 636665758639430000, 9, 4, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1803, 636665758639430000, 9, 5, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1804, 636665758639430000, 9, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1805, 636665758639430000, 9, 2, 2, CAST(100.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1806, 636665758639430000, 9, 3, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1807, 636665758639430000, 9, 4, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1808, 636665758639430000, 9, 5, 2, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1809, 636665758639430000, 9, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1810, 636665758639430000, 9, 2, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1811, 636665758639430000, 9, 3, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1812, 636665758639430000, 9, 4, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1813, 636665758639430000, 9, 5, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1814, 636665758639430000, 9, 1, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1815, 636665758639430000, 9, 2, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1816, 636665758639430000, 9, 3, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1817, 636665758639430000, 9, 4, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1818, 636665758639430000, 9, 5, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1819, 636665758639430000, 9, 1, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1820, 636665758639430000, 9, 2, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1821, 636665758639430000, 9, 3, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1822, 636665758639430000, 9, 4, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1823, 636665758639430000, 9, 5, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-07T15:57:43.943' AS DateTime), CAST(N'2018-07-07T16:00:37.710' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1849, 636665760782500000, 9, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1850, 636665760782500000, 9, 2, 1, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1851, 636665760782500000, 9, 3, 1, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1852, 636665760782500000, 9, 4, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1853, 636665760782500000, 9, 5, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1854, 636665760782500000, 9, 1, 2, CAST(1.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1855, 636665760782500000, 9, 2, 2, CAST(100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1856, 636665760782500000, 9, 3, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1857, 636665760782500000, 9, 4, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1858, 636665760782500000, 9, 5, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1859, 636665760782500000, 9, 1, 3, CAST(2.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1860, 636665760782500000, 9, 2, 3, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1861, 636665760782500000, 9, 3, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1862, 636665760782500000, 9, 4, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1863, 636665760782500000, 9, 5, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1864, 636665760782500000, 9, 1, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1865, 636665760782500000, 9, 2, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1866, 636665760782500000, 9, 3, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1867, 636665760782500000, 9, 4, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1868, 636665760782500000, 9, 5, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1869, 636665760782500000, 9, 1, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1870, 636665760782500000, 9, 2, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1871, 636665760782500000, 9, 3, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1872, 636665760782500000, 9, 4, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1873, 636665760782500000, 9, 5, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-07T16:01:18.250' AS DateTime), CAST(N'2018-07-07T16:01:59.650' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1949, 636660857662230000, 11, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1950, 636660857662230000, 11, 2, 1, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1951, 636660857662230000, 11, 3, 1, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1952, 636660857662230000, 11, 4, 1, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1953, 636660857662230000, 11, 5, 1, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1954, 636660857662230000, 11, 6, 1, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1955, 636660857662230000, 11, 7, 1, CAST(6.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1956, 636660857662230000, 11, 8, 1, CAST(7.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1957, 636660857662230000, 11, 9, 1, CAST(8.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1958, 636660857662230000, 11, 10, 1, CAST(9.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1959, 636660857662230000, 11, 11, 1, CAST(10.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1960, 636660857662230000, 11, 12, 1, CAST(11.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1961, 636660857662230000, 11, 13, 1, CAST(12.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1962, 636660857662230000, 11, 14, 1, CAST(13.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1963, 636660857662230000, 11, 1, 2, CAST(1.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1964, 636660857662230000, 11, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1965, 636660857662230000, 11, 3, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1966, 636660857662230000, 11, 4, 2, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1967, 636660857662230000, 11, 5, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1968, 636660857662230000, 11, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1969, 636660857662230000, 11, 7, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1970, 636660857662230000, 11, 8, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1971, 636660857662230000, 11, 9, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1972, 636660857662230000, 11, 10, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1973, 636660857662230000, 11, 11, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1974, 636660857662230000, 11, 12, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1975, 636660857662230000, 11, 13, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1976, 636660857662230000, 11, 14, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1977, 636660857662230000, 11, 1, 3, CAST(2.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1978, 636660857662230000, 11, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1979, 636660857662230000, 11, 3, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1980, 636660857662230000, 11, 4, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1981, 636660857662230000, 11, 5, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1982, 636660857662230000, 11, 6, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1983, 636660857662230000, 11, 7, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1984, 636660857662230000, 11, 8, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1985, 636660857662230000, 11, 9, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1986, 636660857662230000, 11, 10, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1987, 636660857662230000, 11, 11, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1988, 636660857662230000, 11, 12, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1989, 636660857662230000, 11, 13, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1990, 636660857662230000, 11, 14, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1991, 636660857662230000, 11, 1, 4, CAST(3.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1992, 636660857662230000, 11, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1993, 636660857662230000, 11, 3, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1994, 636660857662230000, 11, 4, 4, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1995, 636660857662230000, 11, 5, 4, CAST(8000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1996, 636660857662230000, 11, 6, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1997, 636660857662230000, 11, 7, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1998, 636660857662230000, 11, 8, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1999, 636660857662230000, 11, 9, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2000, 636660857662230000, 11, 10, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2001, 636660857662230000, 11, 11, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2002, 636660857662230000, 11, 12, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2003, 636660857662230000, 11, 13, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2004, 636660857662230000, 11, 14, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2005, 636660857662230000, 11, 1, 5, CAST(4.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2006, 636660857662230000, 11, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2007, 636660857662230000, 11, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2008, 636660857662230000, 11, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2009, 636660857662230000, 11, 5, 5, CAST(9000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2010, 636660857662230000, 11, 6, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2011, 636660857662230000, 11, 7, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2012, 636660857662230000, 11, 8, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2013, 636660857662230000, 11, 9, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2014, 636660857662230000, 11, 10, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2015, 636660857662230000, 11, 11, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2016, 636660857662230000, 11, 12, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2017, 636660857662230000, 11, 13, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2018, 636660857662230000, 11, 14, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2019, 636660857662230000, 11, 1, 6, CAST(5.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2020, 636660857662230000, 11, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2021, 636660857662230000, 11, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2022, 636660857662230000, 11, 4, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2023, 636660857662230000, 11, 5, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2024, 636660857662230000, 11, 6, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2025, 636660857662230000, 11, 7, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2026, 636660857662230000, 11, 8, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2027, 636660857662230000, 11, 9, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2028, 636660857662230000, 11, 10, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2029, 636660857662230000, 11, 11, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2030, 636660857662230000, 11, 12, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2031, 636660857662230000, 11, 13, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2032, 636660857662230000, 11, 14, 6, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2033, 636660857662230000, 11, 1, 7, CAST(6.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2034, 636660857662230000, 11, 2, 7, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2035, 636660857662230000, 11, 3, 7, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2036, 636660857662230000, 11, 4, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2037, 636660857662230000, 11, 5, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2038, 636660857662230000, 11, 6, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2039, 636660857662230000, 11, 7, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2040, 636660857662230000, 11, 8, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2041, 636660857662230000, 11, 9, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2042, 636660857662230000, 11, 10, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2043, 636660857662230000, 11, 11, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2044, 636660857662230000, 11, 12, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2045, 636660857662230000, 11, 13, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2046, 636660857662230000, 11, 14, 7, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2047, 636660857662230000, 11, 1, 8, CAST(7.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2048, 636660857662230000, 11, 2, 8, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2049, 636660857662230000, 11, 3, 8, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2050, 636660857662230000, 11, 4, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2051, 636660857662230000, 11, 5, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2052, 636660857662230000, 11, 6, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2053, 636660857662230000, 11, 7, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2054, 636660857662230000, 11, 8, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2055, 636660857662230000, 11, 9, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2056, 636660857662230000, 11, 10, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2057, 636660857662230000, 11, 11, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2058, 636660857662230000, 11, 12, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2059, 636660857662230000, 11, 13, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2060, 636660857662230000, 11, 14, 8, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2061, 636660857662230000, 11, 1, 9, CAST(8.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2062, 636660857662230000, 11, 2, 9, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2063, 636660857662230000, 11, 3, 9, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2064, 636660857662230000, 11, 4, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2065, 636660857662230000, 11, 5, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2066, 636660857662230000, 11, 6, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2067, 636660857662230000, 11, 7, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2068, 636660857662230000, 11, 8, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2069, 636660857662230000, 11, 9, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2070, 636660857662230000, 11, 10, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2071, 636660857662230000, 11, 11, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2072, 636660857662230000, 11, 12, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2073, 636660857662230000, 11, 13, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2074, 636660857662230000, 11, 14, 9, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2075, 636660857662230000, 11, 1, 10, CAST(9.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2076, 636660857662230000, 11, 2, 10, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2077, 636660857662230000, 11, 3, 10, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2078, 636660857662230000, 11, 4, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2079, 636660857662230000, 11, 5, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2080, 636660857662230000, 11, 6, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2081, 636660857662230000, 11, 7, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2082, 636660857662230000, 11, 8, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2083, 636660857662230000, 11, 9, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2084, 636660857662230000, 11, 10, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2085, 636660857662230000, 11, 11, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2086, 636660857662230000, 11, 12, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2087, 636660857662230000, 11, 13, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2088, 636660857662230000, 11, 14, 10, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2089, 636660857662230000, 11, 1, 11, CAST(10.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2090, 636660857662230000, 11, 2, 11, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2091, 636660857662230000, 11, 3, 11, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2092, 636660857662230000, 11, 4, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2093, 636660857662230000, 11, 5, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2094, 636660857662230000, 11, 6, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2095, 636660857662230000, 11, 7, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2096, 636660857662230000, 11, 8, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2097, 636660857662230000, 11, 9, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2098, 636660857662230000, 11, 10, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2099, 636660857662230000, 11, 11, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2100, 636660857662230000, 11, 12, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2101, 636660857662230000, 11, 13, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2102, 636660857662230000, 11, 14, 11, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2103, 636660857662230000, 11, 1, 12, CAST(11.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2104, 636660857662230000, 11, 2, 12, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2105, 636660857662230000, 11, 3, 12, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2106, 636660857662230000, 11, 4, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2107, 636660857662230000, 11, 5, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2108, 636660857662230000, 11, 6, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2109, 636660857662230000, 11, 7, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2110, 636660857662230000, 11, 8, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2111, 636660857662230000, 11, 9, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2112, 636660857662230000, 11, 10, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2113, 636660857662230000, 11, 11, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2114, 636660857662230000, 11, 12, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2115, 636660857662230000, 11, 13, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2116, 636660857662230000, 11, 14, 12, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2117, 636660857662230000, 11, 1, 13, CAST(12.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2118, 636660857662230000, 11, 2, 13, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2119, 636660857662230000, 11, 3, 13, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2120, 636660857662230000, 11, 4, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2121, 636660857662230000, 11, 5, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2122, 636660857662230000, 11, 6, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2123, 636660857662230000, 11, 7, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2124, 636660857662230000, 11, 8, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2125, 636660857662230000, 11, 9, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2126, 636660857662230000, 11, 10, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2127, 636660857662230000, 11, 11, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2128, 636660857662230000, 11, 12, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2129, 636660857662230000, 11, 13, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2130, 636660857662230000, 11, 14, 13, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2131, 636660857662230000, 11, 1, 14, CAST(13.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2132, 636660857662230000, 11, 2, 14, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2133, 636660857662230000, 11, 3, 14, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2134, 636660857662230000, 11, 4, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2135, 636660857662230000, 11, 5, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2136, 636660857662230000, 11, 6, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2137, 636660857662230000, 11, 7, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2138, 636660857662230000, 11, 8, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2139, 636660857662230000, 11, 9, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2140, 636660857662230000, 11, 10, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2141, 636660857662230000, 11, 11, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2142, 636660857662230000, 11, 12, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2143, 636660857662230000, 11, 13, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2144, 636660857662230000, 11, 14, 14, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-01T23:49:26.223' AS DateTime), CAST(N'2018-07-07T22:04:12.850' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2145, 636660596817800000, 7, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2146, 636660596817800000, 7, 2, 1, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2147, 636660596817800000, 7, 3, 1, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2148, 636660596817800000, 7, 4, 1, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2149, 636660596817800000, 7, 5, 1, CAST(70.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2150, 636660596817800000, 7, 1, 2, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2151, 636660596817800000, 7, 2, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2152, 636660596817800000, 7, 3, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2153, 636660596817800000, 7, 4, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2154, 636660596817800000, 7, 5, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2155, 636660596817800000, 7, 1, 3, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2156, 636660596817800000, 7, 2, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2157, 636660596817800000, 7, 3, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2158, 636660596817800000, 7, 4, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2159, 636660596817800000, 7, 5, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2160, 636660596817800000, 7, 1, 4, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2161, 636660596817800000, 7, 2, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2162, 636660596817800000, 7, 3, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2163, 636660596817800000, 7, 4, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2164, 636660596817800000, 7, 5, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2165, 636660596817800000, 7, 1, 5, CAST(70.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2166, 636660596817800000, 7, 2, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2167, 636660596817800000, 7, 3, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2168, 636660596817800000, 7, 4, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2169, 636660596817800000, 7, 5, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2170, 636660596817800000, 7, 6, 1, CAST(80.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2171, 636660596817800000, 7, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2172, 636660596817800000, 7, 6, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2173, 636660596817800000, 7, 6, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2174, 636660596817800000, 7, 6, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2175, 636660596817800000, 7, 1, 6, CAST(80.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2176, 636660596817800000, 7, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2177, 636660596817800000, 7, 3, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2178, 636660596817800000, 7, 4, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2179, 636660596817800000, 7, 5, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2180, 636660596817800000, 7, 6, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2181, 636660596817800000, 7, 7, 1, CAST(90.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2182, 636660596817800000, 7, 7, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2183, 636660596817800000, 7, 7, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2184, 636660596817800000, 7, 7, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2185, 636660596817800000, 7, 7, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2186, 636660596817800000, 7, 7, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2187, 636660596817800000, 7, 1, 7, CAST(90.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2188, 636660596817800000, 7, 2, 7, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2189, 636660596817800000, 7, 3, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2190, 636660596817800000, 7, 4, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2191, 636660596817800000, 7, 5, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2192, 636660596817800000, 7, 6, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2193, 636660596817800000, 7, 7, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-01T16:34:41.780' AS DateTime), CAST(N'2018-07-07T22:34:51.667' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2402, 636655408344330000, 8, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2403, 636655408344330000, 8, 2, 1, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2404, 636655408344330000, 8, 3, 1, CAST(20.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2405, 636655408344330000, 8, 4, 1, CAST(30.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2406, 636655408344330000, 8, 5, 1, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2407, 636655408344330000, 8, 6, 1, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2408, 636655408344330000, 8, 7, 1, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2409, 636655408344330000, 8, 8, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2410, 636655408344330000, 8, 1, 2, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2411, 636655408344330000, 8, 2, 2, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2412, 636655408344330000, 8, 3, 2, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2413, 636655408344330000, 8, 4, 2, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2414, 636655408344330000, 8, 5, 2, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2415, 636655408344330000, 8, 6, 2, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2416, 636655408344330000, 8, 7, 2, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2417, 636655408344330000, 8, 8, 2, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2418, 636655408344330000, 8, 1, 3, CAST(20.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2419, 636655408344330000, 8, 2, 3, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2420, 636655408344330000, 8, 3, 3, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2421, 636655408344330000, 8, 4, 3, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2422, 636655408344330000, 8, 5, 3, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2423, 636655408344330000, 8, 6, 3, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2424, 636655408344330000, 8, 7, 3, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2425, 636655408344330000, 8, 8, 3, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2426, 636655408344330000, 8, 1, 4, CAST(30.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2427, 636655408344330000, 8, 2, 4, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2428, 636655408344330000, 8, 3, 4, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2429, 636655408344330000, 8, 4, 4, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2430, 636655408344330000, 8, 5, 4, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2431, 636655408344330000, 8, 6, 4, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2432, 636655408344330000, 8, 7, 4, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2433, 636655408344330000, 8, 8, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2434, 636655408344330000, 8, 1, 5, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2435, 636655408344330000, 8, 2, 5, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2436, 636655408344330000, 8, 3, 5, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2437, 636655408344330000, 8, 4, 5, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2438, 636655408344330000, 8, 5, 5, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2439, 636655408344330000, 8, 6, 5, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2440, 636655408344330000, 8, 7, 5, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2441, 636655408344330000, 8, 8, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2442, 636655408344330000, 8, 1, 6, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2443, 636655408344330000, 8, 2, 6, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2444, 636655408344330000, 8, 3, 6, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2445, 636655408344330000, 8, 4, 6, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2446, 636655408344330000, 8, 5, 6, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2447, 636655408344330000, 8, 6, 6, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2448, 636655408344330000, 8, 7, 6, CAST(1100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2449, 636655408344330000, 8, 8, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2450, 636655408344330000, 8, 1, 7, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2451, 636655408344330000, 8, 2, 7, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2452, 636655408344330000, 8, 3, 7, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2453, 636655408344330000, 8, 4, 7, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2454, 636655408344330000, 8, 5, 7, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2455, 636655408344330000, 8, 6, 7, CAST(1100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2456, 636655408344330000, 8, 7, 7, CAST(1200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2457, 636655408344330000, 8, 8, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2458, 636655408344330000, 8, 1, 8, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2459, 636655408344330000, 8, 2, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2460, 636655408344330000, 8, 3, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2461, 636655408344330000, 8, 4, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2462, 636655408344330000, 8, 5, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2463, 636655408344330000, 8, 6, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2464, 636655408344330000, 8, 7, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2465, 636655408344330000, 8, 8, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-07-08T15:21:38.060' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3096, 636666602696270000, 11, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3097, 636666602696270000, 11, 2, 1, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3098, 636666602696270000, 11, 3, 1, CAST(20.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3099, 636666602696270000, 11, 4, 1, CAST(30.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3100, 636666602696270000, 11, 5, 1, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3101, 636666602696270000, 11, 6, 1, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3102, 636666602696270000, 11, 7, 1, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3103, 636666602696270000, 11, 8, 1, CAST(7.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3104, 636666602696270000, 11, 9, 1, CAST(8.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3105, 636666602696270000, 11, 10, 1, CAST(9.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3106, 636666602696270000, 11, 11, 1, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3107, 636666602696270000, 11, 12, 1, CAST(11.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3108, 636666602696270000, 11, 13, 1, CAST(12.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3109, 636666602696270000, 11, 14, 1, CAST(13.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3110, 636666602696270000, 11, 1, 2, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3111, 636666602696270000, 11, 2, 2, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3112, 636666602696270000, 11, 3, 2, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3113, 636666602696270000, 11, 4, 2, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3114, 636666602696270000, 11, 5, 2, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3115, 636666602696270000, 11, 6, 2, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3116, 636666602696270000, 11, 7, 2, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3117, 636666602696270000, 11, 8, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3118, 636666602696270000, 11, 9, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3119, 636666602696270000, 11, 10, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3120, 636666602696270000, 11, 11, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3121, 636666602696270000, 11, 12, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3122, 636666602696270000, 11, 13, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3123, 636666602696270000, 11, 14, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3124, 636666602696270000, 11, 1, 3, CAST(20.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3125, 636666602696270000, 11, 2, 3, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3126, 636666602696270000, 11, 3, 3, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3127, 636666602696270000, 11, 4, 3, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3128, 636666602696270000, 11, 5, 3, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3129, 636666602696270000, 11, 6, 3, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3130, 636666602696270000, 11, 7, 3, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3131, 636666602696270000, 11, 8, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3132, 636666602696270000, 11, 9, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3133, 636666602696270000, 11, 10, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3134, 636666602696270000, 11, 11, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3135, 636666602696270000, 11, 12, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3136, 636666602696270000, 11, 13, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3137, 636666602696270000, 11, 14, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3138, 636666602696270000, 11, 1, 4, CAST(30.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3139, 636666602696270000, 11, 2, 4, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3140, 636666602696270000, 11, 3, 4, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3141, 636666602696270000, 11, 4, 4, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3142, 636666602696270000, 11, 5, 4, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3143, 636666602696270000, 11, 6, 4, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3144, 636666602696270000, 11, 7, 4, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3145, 636666602696270000, 11, 8, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3146, 636666602696270000, 11, 9, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3147, 636666602696270000, 11, 10, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3148, 636666602696270000, 11, 11, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3149, 636666602696270000, 11, 12, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3150, 636666602696270000, 11, 13, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3151, 636666602696270000, 11, 14, 4, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3152, 636666602696270000, 11, 1, 5, CAST(40.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3153, 636666602696270000, 11, 2, 5, CAST(500.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3154, 636666602696270000, 11, 3, 5, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3155, 636666602696270000, 11, 4, 5, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3156, 636666602696270000, 11, 5, 5, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3157, 636666602696270000, 11, 6, 5, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3158, 636666602696270000, 11, 7, 5, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3159, 636666602696270000, 11, 8, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3160, 636666602696270000, 11, 9, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3161, 636666602696270000, 11, 10, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3162, 636666602696270000, 11, 11, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3163, 636666602696270000, 11, 12, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3164, 636666602696270000, 11, 13, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3165, 636666602696270000, 11, 14, 5, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3166, 636666602696270000, 11, 1, 6, CAST(50.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3167, 636666602696270000, 11, 2, 6, CAST(600.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3168, 636666602696270000, 11, 3, 6, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3169, 636666602696270000, 11, 4, 6, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3170, 636666602696270000, 11, 5, 6, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3171, 636666602696270000, 11, 6, 6, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3172, 636666602696270000, 11, 7, 6, CAST(1100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3173, 636666602696270000, 11, 8, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3174, 636666602696270000, 11, 9, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3175, 636666602696270000, 11, 10, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3176, 636666602696270000, 11, 11, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3177, 636666602696270000, 11, 12, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3178, 636666602696270000, 11, 13, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3179, 636666602696270000, 11, 14, 6, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3180, 636666602696270000, 11, 1, 7, CAST(60.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3181, 636666602696270000, 11, 2, 7, CAST(700.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3182, 636666602696270000, 11, 3, 7, CAST(800.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3183, 636666602696270000, 11, 4, 7, CAST(900.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3184, 636666602696270000, 11, 5, 7, CAST(1000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3185, 636666602696270000, 11, 6, 7, CAST(1100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3186, 636666602696270000, 11, 7, 7, CAST(1200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3187, 636666602696270000, 11, 8, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3188, 636666602696270000, 11, 9, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3189, 636666602696270000, 11, 10, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3190, 636666602696270000, 11, 11, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3191, 636666602696270000, 11, 12, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3192, 636666602696270000, 11, 13, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3193, 636666602696270000, 11, 14, 7, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3194, 636666602696270000, 11, 1, 8, CAST(7.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3195, 636666602696270000, 11, 2, 8, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3196, 636666602696270000, 11, 3, 8, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3197, 636666602696270000, 11, 4, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3198, 636666602696270000, 11, 5, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3199, 636666602696270000, 11, 6, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3200, 636666602696270000, 11, 7, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3201, 636666602696270000, 11, 8, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3202, 636666602696270000, 11, 9, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3203, 636666602696270000, 11, 10, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3204, 636666602696270000, 11, 11, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3205, 636666602696270000, 11, 12, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3206, 636666602696270000, 11, 13, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3207, 636666602696270000, 11, 14, 8, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3208, 636666602696270000, 11, 1, 9, CAST(8.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3209, 636666602696270000, 11, 2, 9, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3210, 636666602696270000, 11, 3, 9, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3211, 636666602696270000, 11, 4, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3212, 636666602696270000, 11, 5, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3213, 636666602696270000, 11, 6, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3214, 636666602696270000, 11, 7, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3215, 636666602696270000, 11, 8, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3216, 636666602696270000, 11, 9, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3217, 636666602696270000, 11, 10, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3218, 636666602696270000, 11, 11, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3219, 636666602696270000, 11, 12, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3220, 636666602696270000, 11, 13, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3221, 636666602696270000, 11, 14, 9, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3222, 636666602696270000, 11, 1, 10, CAST(9.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3223, 636666602696270000, 11, 2, 10, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3224, 636666602696270000, 11, 3, 10, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3225, 636666602696270000, 11, 4, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3226, 636666602696270000, 11, 5, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3227, 636666602696270000, 11, 6, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3228, 636666602696270000, 11, 7, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3229, 636666602696270000, 11, 8, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3230, 636666602696270000, 11, 9, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3231, 636666602696270000, 11, 10, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3232, 636666602696270000, 11, 11, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3233, 636666602696270000, 11, 12, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3234, 636666602696270000, 11, 13, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3235, 636666602696270000, 11, 14, 10, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3236, 636666602696270000, 11, 1, 11, CAST(10.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3237, 636666602696270000, 11, 2, 11, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3238, 636666602696270000, 11, 3, 11, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3239, 636666602696270000, 11, 4, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3240, 636666602696270000, 11, 5, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3241, 636666602696270000, 11, 6, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3242, 636666602696270000, 11, 7, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3243, 636666602696270000, 11, 8, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3244, 636666602696270000, 11, 9, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3245, 636666602696270000, 11, 10, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3246, 636666602696270000, 11, 11, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3247, 636666602696270000, 11, 12, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3248, 636666602696270000, 11, 13, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3249, 636666602696270000, 11, 14, 11, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3250, 636666602696270000, 11, 1, 12, CAST(11.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3251, 636666602696270000, 11, 2, 12, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3252, 636666602696270000, 11, 3, 12, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3253, 636666602696270000, 11, 4, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3254, 636666602696270000, 11, 5, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3255, 636666602696270000, 11, 6, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3256, 636666602696270000, 11, 7, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3257, 636666602696270000, 11, 8, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3258, 636666602696270000, 11, 9, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3259, 636666602696270000, 11, 10, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3260, 636666602696270000, 11, 11, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3261, 636666602696270000, 11, 12, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3262, 636666602696270000, 11, 13, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3263, 636666602696270000, 11, 14, 12, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3264, 636666602696270000, 11, 1, 13, CAST(12.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3265, 636666602696270000, 11, 2, 13, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3266, 636666602696270000, 11, 3, 13, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3267, 636666602696270000, 11, 4, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3268, 636666602696270000, 11, 5, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3269, 636666602696270000, 11, 6, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3270, 636666602696270000, 11, 7, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3271, 636666602696270000, 11, 8, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3272, 636666602696270000, 11, 9, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3273, 636666602696270000, 11, 10, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3274, 636666602696270000, 11, 11, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3275, 636666602696270000, 11, 12, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3276, 636666602696270000, 11, 13, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3277, 636666602696270000, 11, 14, 13, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3278, 636666602696270000, 11, 1, 14, CAST(13.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3279, 636666602696270000, 11, 2, 14, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3280, 636666602696270000, 11, 3, 14, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3281, 636666602696270000, 11, 4, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3282, 636666602696270000, 11, 5, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3283, 636666602696270000, 11, 6, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3284, 636666602696270000, 11, 7, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3285, 636666602696270000, 11, 8, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3286, 636666602696270000, 11, 9, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3287, 636666602696270000, 11, 10, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3288, 636666602696270000, 11, 11, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3289, 636666602696270000, 11, 12, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3290, 636666602696270000, 11, 13, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3291, 636666602696270000, 11, 14, 14, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3292, 636666602696270000, 11, 1, 15, CAST(14.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3293, 636666602696270000, 11, 2, 15, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3294, 636666602696270000, 11, 3, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3295, 636666602696270000, 11, 4, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3296, 636666602696270000, 11, 5, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3297, 636666602696270000, 11, 6, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3298, 636666602696270000, 11, 7, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3299, 636666602696270000, 11, 8, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3300, 636666602696270000, 11, 9, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3301, 636666602696270000, 11, 10, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3302, 636666602696270000, 11, 11, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3303, 636666602696270000, 11, 12, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3304, 636666602696270000, 11, 13, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3305, 636666602696270000, 11, 14, 15, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3306, 636666602696270000, 11, 1, 16, CAST(15.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3307, 636666602696270000, 11, 2, 16, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3308, 636666602696270000, 11, 3, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3309, 636666602696270000, 11, 4, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3310, 636666602696270000, 11, 5, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3311, 636666602696270000, 11, 6, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3312, 636666602696270000, 11, 7, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3313, 636666602696270000, 11, 8, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3314, 636666602696270000, 11, 9, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3315, 636666602696270000, 11, 10, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3316, 636666602696270000, 11, 11, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3317, 636666602696270000, 11, 12, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3318, 636666602696270000, 11, 13, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3319, 636666602696270000, 11, 14, 16, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3320, 636666602696270000, 11, 1, 17, CAST(16.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3321, 636666602696270000, 11, 2, 17, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3322, 636666602696270000, 11, 3, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3323, 636666602696270000, 11, 4, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3324, 636666602696270000, 11, 5, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3325, 636666602696270000, 11, 6, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3326, 636666602696270000, 11, 7, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3327, 636666602696270000, 11, 8, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3328, 636666602696270000, 11, 9, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3329, 636666602696270000, 11, 10, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3330, 636666602696270000, 11, 11, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3331, 636666602696270000, 11, 12, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3332, 636666602696270000, 11, 13, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3333, 636666602696270000, 11, 14, 17, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-08T15:24:29.627' AS DateTime), CAST(N'2018-07-13T22:02:49.623' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3516, 636671831541870000, 8, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3517, 636671831541870000, 8, 2, 1, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3518, 636671831541870000, 8, 3, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3519, 636671831541870000, 8, 4, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3520, 636671831541870000, 8, 5, 1, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3521, 636671831541870000, 8, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3522, 636671831541870000, 8, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3523, 636671831541870000, 8, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3524, 636671831541870000, 8, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3525, 636671831541870000, 8, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3526, 636671831541870000, 8, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3527, 636671831541870000, 8, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3528, 636671831541870000, 8, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3529, 636671831541870000, 8, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3530, 636671831541870000, 8, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3531, 636671831541870000, 8, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3532, 636671831541870000, 8, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3533, 636671831541870000, 8, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3534, 636671831541870000, 8, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3535, 636671831541870000, 8, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3536, 636671831541870000, 8, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3537, 636671831541870000, 8, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3538, 636671831541870000, 8, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3539, 636671831541870000, 8, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3540, 636671831541870000, 8, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:39:14.187' AS DateTime), CAST(N'2018-07-14T16:39:14.190' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3541, 636671832567570000, 11, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3542, 636671832567570000, 11, 2, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3543, 636671832567570000, 11, 3, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3544, 636671832567570000, 11, 4, 1, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3545, 636671832567570000, 11, 5, 1, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3546, 636671832567570000, 11, 1, 2, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3547, 636671832567570000, 11, 2, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3548, 636671832567570000, 11, 3, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3549, 636671832567570000, 11, 4, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3550, 636671832567570000, 11, 5, 2, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3551, 636671832567570000, 11, 1, 3, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3552, 636671832567570000, 11, 2, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3553, 636671832567570000, 11, 3, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3554, 636671832567570000, 11, 4, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3555, 636671832567570000, 11, 5, 3, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3556, 636671832567570000, 11, 1, 4, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3557, 636671832567570000, 11, 2, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3558, 636671832567570000, 11, 3, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3559, 636671832567570000, 11, 4, 4, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3560, 636671832567570000, 11, 5, 4, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3561, 636671832567570000, 11, 1, 5, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3562, 636671832567570000, 11, 2, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3563, 636671832567570000, 11, 3, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3564, 636671832567570000, 11, 4, 5, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3565, 636671832567570000, 11, 5, 5, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T16:40:56.757' AS DateTime), CAST(N'2018-07-14T16:40:56.760' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3999, 636671870501830000, 12, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4000, 636671870501830000, 12, 2, 1, CAST(100.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4001, 636671870501830000, 12, 3, 1, CAST(200.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4002, 636671870501830000, 12, 4, 1, CAST(300.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4003, 636671870501830000, 12, 5, 1, CAST(400.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4004, 636671870501830000, 12, 1, 2, CAST(100.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4005, 636671870501830000, 12, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4006, 636671870501830000, 12, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4007, 636671870501830000, 12, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4008, 636671870501830000, 12, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4009, 636671870501830000, 12, 1, 3, CAST(200.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4010, 636671870501830000, 12, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4011, 636671870501830000, 12, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4012, 636671870501830000, 12, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4013, 636671870501830000, 12, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4014, 636671870501830000, 12, 1, 4, CAST(300.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4015, 636671870501830000, 12, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4016, 636671870501830000, 12, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4017, 636671870501830000, 12, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4018, 636671870501830000, 12, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4019, 636671870501830000, 12, 1, 5, CAST(400.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4020, 636671870501830000, 12, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4021, 636671870501830000, 12, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4022, 636671870501830000, 12, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4023, 636671870501830000, 12, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4024, 636671870501830000, 12, 1, 6, CAST(500.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4025, 636671870501830000, 12, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4026, 636671870501830000, 12, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4027, 636671870501830000, 12, 4, 6, CAST(8000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4028, 636671870501830000, 12, 5, 6, CAST(9000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4029, 636671870501830000, 12, 1, 7, CAST(600.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4030, 636671870501830000, 12, 2, 7, CAST(7000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4031, 636671870501830000, 12, 3, 7, CAST(8000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4032, 636671870501830000, 12, 4, 7, CAST(9000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4033, 636671870501830000, 12, 5, 7, CAST(10000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4034, 636671870501830000, 12, 6, 1, CAST(500.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4035, 636671870501830000, 12, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4036, 636671870501830000, 12, 6, 3, CAST(7000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4037, 636671870501830000, 12, 6, 4, CAST(8000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4038, 636671870501830000, 12, 6, 5, CAST(9000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4039, 636671870501830000, 12, 6, 6, CAST(10000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4040, 636671870501830000, 12, 6, 7, CAST(11000.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4041, 636671870501830000, 12, 7, 1, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4042, 636671870501830000, 12, 7, 2, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4043, 636671870501830000, 12, 7, 3, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4044, 636671870501830000, 12, 7, 4, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4045, 636671870501830000, 12, 7, 5, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4046, 636671870501830000, 12, 7, 6, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4047, 636671870501830000, 12, 7, 7, CAST(0.00 AS Decimal(18, 2)), 0, 2, NULL, NULL, CAST(N'2018-07-14T17:44:10.183' AS DateTime), CAST(N'2018-07-14T17:44:10.183' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4152, 636671870099130000, 12, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4153, 636671870099130000, 12, 2, 1, CAST(100.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4154, 636671870099130000, 12, 3, 1, CAST(200.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4155, 636671870099130000, 12, 4, 1, CAST(300.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4156, 636671870099130000, 12, 5, 1, CAST(400.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4157, 636671870099130000, 12, 1, 2, CAST(100.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4158, 636671870099130000, 12, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4159, 636671870099130000, 12, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4160, 636671870099130000, 12, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4161, 636671870099130000, 12, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4162, 636671870099130000, 12, 1, 3, CAST(200.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4163, 636671870099130000, 12, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4164, 636671870099130000, 12, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4165, 636671870099130000, 12, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4166, 636671870099130000, 12, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4167, 636671870099130000, 12, 1, 4, CAST(300.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4168, 636671870099130000, 12, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4169, 636671870099130000, 12, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4170, 636671870099130000, 12, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4171, 636671870099130000, 12, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4172, 636671870099130000, 12, 1, 5, CAST(400.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4173, 636671870099130000, 12, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4174, 636671870099130000, 12, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4175, 636671870099130000, 12, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4176, 636671870099130000, 12, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4177, 636671870099130000, 12, 6, 1, CAST(500.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4178, 636671870099130000, 12, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4179, 636671870099130000, 12, 6, 3, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4180, 636671870099130000, 12, 6, 4, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4181, 636671870099130000, 12, 6, 5, CAST(0.00 AS Decimal(18, 2)), 0, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T17:46:22.990' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4480, 636671871245500000, 12, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4481, 636671871245500000, 12, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4482, 636671871245500000, 12, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4483, 636671871245500000, 12, 4, 1, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4484, 636671871245500000, 12, 5, 1, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4485, 636671871245500000, 12, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4486, 636671871245500000, 12, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4487, 636671871245500000, 12, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4488, 636671871245500000, 12, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4489, 636671871245500000, 12, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4490, 636671871245500000, 12, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4491, 636671871245500000, 12, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4492, 636671871245500000, 12, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4493, 636671871245500000, 12, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4494, 636671871245500000, 12, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4495, 636671871245500000, 12, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4496, 636671871245500000, 12, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4497, 636671871245500000, 12, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4498, 636671871245500000, 12, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4499, 636671871245500000, 12, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4500, 636671871245500000, 12, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4501, 636671871245500000, 12, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4502, 636671871245500000, 12, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4503, 636671871245500000, 12, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4504, 636671871245500000, 12, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 1, NULL, NULL, CAST(N'2018-07-14T17:45:24.550' AS DateTime), CAST(N'2018-07-14T18:05:10.097' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4505, 636671870868600000, 12, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4506, 636671870868600000, 12, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4507, 636671870868600000, 12, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4508, 636671870868600000, 12, 4, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4509, 636671870868600000, 12, 5, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4510, 636671870868600000, 12, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4511, 636671870868600000, 12, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4512, 636671870868600000, 12, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4513, 636671870868600000, 12, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4514, 636671870868600000, 12, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4515, 636671870868600000, 12, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4516, 636671870868600000, 12, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4517, 636671870868600000, 12, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4518, 636671870868600000, 12, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4519, 636671870868600000, 12, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4520, 636671870868600000, 12, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4521, 636671870868600000, 12, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4522, 636671870868600000, 12, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4523, 636671870868600000, 12, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4524, 636671870868600000, 12, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4525, 636671870868600000, 12, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4526, 636671870868600000, 12, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4527, 636671870868600000, 12, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4528, 636671870868600000, 12, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4529, 636671870868600000, 12, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4530, 636671870868600000, 12, 1, 6, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4531, 636671870868600000, 12, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4532, 636671870868600000, 12, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4533, 636671870868600000, 12, 4, 6, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4534, 636671870868600000, 12, 5, 6, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4535, 636671870868600000, 12, 1, 7, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4536, 636671870868600000, 12, 2, 7, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4537, 636671870868600000, 12, 3, 7, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4538, 636671870868600000, 12, 4, 7, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4539, 636671870868600000, 12, 5, 7, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T17:44:46.860' AS DateTime), CAST(N'2018-07-14T18:05:29.420' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4540, 636671888905300000, 10, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4541, 636671888905300000, 10, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4542, 636671888905300000, 10, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4543, 636671888905300000, 10, 4, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4544, 636671888905300000, 10, 5, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4545, 636671888905300000, 10, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4546, 636671888905300000, 10, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4547, 636671888905300000, 10, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4548, 636671888905300000, 10, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4549, 636671888905300000, 10, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4550, 636671888905300000, 10, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4551, 636671888905300000, 10, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4552, 636671888905300000, 10, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4553, 636671888905300000, 10, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4554, 636671888905300000, 10, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4555, 636671888905300000, 10, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4556, 636671888905300000, 10, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4557, 636671888905300000, 10, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4558, 636671888905300000, 10, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4559, 636671888905300000, 10, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4560, 636671888905300000, 10, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4561, 636671888905300000, 10, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4562, 636671888905300000, 10, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4563, 636671888905300000, 10, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4564, 636671888905300000, 10, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4565, 636671888905300000, 10, 1, 6, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4566, 636671888905300000, 10, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4567, 636671888905300000, 10, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4568, 636671888905300000, 10, 4, 6, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4569, 636671888905300000, 10, 5, 6, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4570, 636671888905300000, 10, 1, 7, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4571, 636671888905300000, 10, 2, 7, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4572, 636671888905300000, 10, 3, 7, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4573, 636671888905300000, 10, 4, 7, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4574, 636671888905300000, 10, 5, 7, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4575, 636671888905300000, 10, 1, 8, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4576, 636671888905300000, 10, 2, 8, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4577, 636671888905300000, 10, 3, 8, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4578, 636671888905300000, 10, 4, 8, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4579, 636671888905300000, 10, 5, 8, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4580, 636671888905300000, 10, 1, 9, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4581, 636671888905300000, 10, 2, 9, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4582, 636671888905300000, 10, 3, 9, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4583, 636671888905300000, 10, 4, 9, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4584, 636671888905300000, 10, 5, 9, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4585, 636671888905300000, 10, 1, 10, CAST(900.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4586, 636671888905300000, 10, 2, 10, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4587, 636671888905300000, 10, 3, 10, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4588, 636671888905300000, 10, 4, 10, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4589, 636671888905300000, 10, 5, 10, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4590, 636671888905300000, 10, 1, 11, CAST(1000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4591, 636671888905300000, 10, 2, 11, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4592, 636671888905300000, 10, 3, 11, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4593, 636671888905300000, 10, 4, 11, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4594, 636671888905300000, 10, 5, 11, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4595, 636671888905300000, 10, 6, 1, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4596, 636671888905300000, 10, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4597, 636671888905300000, 10, 6, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4598, 636671888905300000, 10, 6, 4, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4599, 636671888905300000, 10, 6, 5, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4600, 636671888905300000, 10, 6, 6, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4601, 636671888905300000, 10, 6, 7, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4602, 636671888905300000, 10, 6, 8, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4603, 636671888905300000, 10, 6, 9, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4604, 636671888905300000, 10, 6, 10, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4605, 636671888905300000, 10, 6, 11, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4606, 636671888905300000, 10, 7, 1, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4607, 636671888905300000, 10, 7, 2, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4608, 636671888905300000, 10, 7, 3, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4609, 636671888905300000, 10, 7, 4, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4610, 636671888905300000, 10, 7, 5, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4611, 636671888905300000, 10, 7, 6, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4612, 636671888905300000, 10, 7, 7, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4613, 636671888905300000, 10, 7, 8, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4614, 636671888905300000, 10, 7, 9, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4615, 636671888905300000, 10, 7, 10, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4616, 636671888905300000, 10, 7, 11, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4617, 636671888905300000, 10, 8, 1, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4618, 636671888905300000, 10, 8, 2, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4619, 636671888905300000, 10, 8, 3, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4620, 636671888905300000, 10, 8, 4, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4621, 636671888905300000, 10, 8, 5, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4622, 636671888905300000, 10, 8, 6, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4623, 636671888905300000, 10, 8, 7, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4624, 636671888905300000, 10, 8, 8, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4625, 636671888905300000, 10, 8, 9, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4626, 636671888905300000, 10, 8, 10, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4627, 636671888905300000, 10, 8, 11, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4628, 636671888905300000, 10, 9, 1, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4629, 636671888905300000, 10, 9, 2, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4630, 636671888905300000, 10, 9, 3, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4631, 636671888905300000, 10, 9, 4, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4632, 636671888905300000, 10, 9, 5, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4633, 636671888905300000, 10, 9, 6, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4634, 636671888905300000, 10, 9, 7, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4635, 636671888905300000, 10, 9, 8, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4636, 636671888905300000, 10, 9, 9, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4637, 636671888905300000, 10, 9, 10, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4638, 636671888905300000, 10, 9, 11, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:14:50.530' AS DateTime), CAST(N'2018-07-14T18:14:50.537' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4639, 636671889741500000, 7, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4640, 636671889741500000, 7, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4641, 636671889741500000, 7, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4642, 636671889741500000, 7, 4, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4643, 636671889741500000, 7, 5, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4644, 636671889741500000, 7, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4645, 636671889741500000, 7, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4646, 636671889741500000, 7, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4647, 636671889741500000, 7, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4648, 636671889741500000, 7, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4649, 636671889741500000, 7, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4650, 636671889741500000, 7, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4651, 636671889741500000, 7, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4652, 636671889741500000, 7, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4653, 636671889741500000, 7, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4654, 636671889741500000, 7, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4655, 636671889741500000, 7, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4656, 636671889741500000, 7, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4657, 636671889741500000, 7, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4658, 636671889741500000, 7, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4659, 636671889741500000, 7, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4660, 636671889741500000, 7, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4661, 636671889741500000, 7, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4662, 636671889741500000, 7, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4663, 636671889741500000, 7, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4664, 636671889741500000, 7, 6, 1, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4665, 636671889741500000, 7, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4666, 636671889741500000, 7, 6, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4667, 636671889741500000, 7, 6, 4, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4668, 636671889741500000, 7, 6, 5, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4669, 636671889741500000, 7, 7, 1, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4670, 636671889741500000, 7, 7, 2, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4671, 636671889741500000, 7, 7, 3, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4672, 636671889741500000, 7, 7, 4, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4673, 636671889741500000, 7, 7, 5, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4674, 636671889741500000, 7, 8, 1, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4675, 636671889741500000, 7, 8, 2, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4676, 636671889741500000, 7, 8, 3, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4677, 636671889741500000, 7, 8, 4, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4678, 636671889741500000, 7, 8, 5, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4679, 636671889741500000, 7, 9, 1, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4680, 636671889741500000, 7, 9, 2, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4681, 636671889741500000, 7, 9, 3, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4682, 636671889741500000, 7, 9, 4, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4683, 636671889741500000, 7, 9, 5, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4684, 636671889741500000, 7, 1, 6, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4685, 636671889741500000, 7, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4686, 636671889741500000, 7, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4687, 636671889741500000, 7, 4, 6, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4688, 636671889741500000, 7, 5, 6, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4689, 636671889741500000, 7, 6, 6, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4690, 636671889741500000, 7, 7, 6, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4691, 636671889741500000, 7, 8, 6, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4692, 636671889741500000, 7, 9, 6, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4693, 636671889741500000, 7, 1, 7, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4694, 636671889741500000, 7, 2, 7, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4695, 636671889741500000, 7, 3, 7, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4696, 636671889741500000, 7, 4, 7, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4697, 636671889741500000, 7, 5, 7, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4698, 636671889741500000, 7, 6, 7, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4699, 636671889741500000, 7, 7, 7, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4700, 636671889741500000, 7, 8, 7, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4701, 636671889741500000, 7, 9, 7, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4702, 636671889741500000, 7, 1, 8, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4703, 636671889741500000, 7, 2, 8, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4704, 636671889741500000, 7, 3, 8, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4705, 636671889741500000, 7, 4, 8, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4706, 636671889741500000, 7, 5, 8, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4707, 636671889741500000, 7, 6, 8, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4708, 636671889741500000, 7, 7, 8, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4709, 636671889741500000, 7, 8, 8, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4710, 636671889741500000, 7, 9, 8, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4711, 636671889741500000, 7, 1, 9, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4712, 636671889741500000, 7, 2, 9, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4713, 636671889741500000, 7, 3, 9, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4714, 636671889741500000, 7, 4, 9, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4715, 636671889741500000, 7, 5, 9, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4716, 636671889741500000, 7, 6, 9, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4717, 636671889741500000, 7, 7, 9, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4718, 636671889741500000, 7, 8, 9, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4719, 636671889741500000, 7, 9, 9, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4720, 636671889741500000, 7, 1, 10, CAST(900.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4721, 636671889741500000, 7, 2, 10, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4722, 636671889741500000, 7, 3, 10, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4723, 636671889741500000, 7, 4, 10, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4724, 636671889741500000, 7, 5, 10, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4725, 636671889741500000, 7, 6, 10, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4726, 636671889741500000, 7, 7, 10, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4727, 636671889741500000, 7, 8, 10, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4728, 636671889741500000, 7, 9, 10, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4729, 636671889741500000, 7, 1, 11, CAST(1000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4730, 636671889741500000, 7, 2, 11, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4731, 636671889741500000, 7, 3, 11, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4732, 636671889741500000, 7, 4, 11, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4733, 636671889741500000, 7, 5, 11, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4734, 636671889741500000, 7, 6, 11, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4735, 636671889741500000, 7, 7, 11, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4736, 636671889741500000, 7, 8, 11, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4737, 636671889741500000, 7, 9, 11, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4738, 636671889741500000, 7, 1, 12, CAST(1100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4739, 636671889741500000, 7, 2, 12, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4740, 636671889741500000, 7, 3, 12, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4741, 636671889741500000, 7, 4, 12, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4742, 636671889741500000, 7, 5, 12, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4743, 636671889741500000, 7, 6, 12, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4744, 636671889741500000, 7, 7, 12, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4745, 636671889741500000, 7, 8, 12, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4746, 636671889741500000, 7, 9, 12, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4747, 636671889741500000, 7, 1, 13, CAST(1200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4748, 636671889741500000, 7, 2, 13, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4749, 636671889741500000, 7, 3, 13, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4750, 636671889741500000, 7, 4, 13, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4751, 636671889741500000, 7, 5, 13, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4752, 636671889741500000, 7, 6, 13, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4753, 636671889741500000, 7, 7, 13, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4754, 636671889741500000, 7, 8, 13, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4755, 636671889741500000, 7, 9, 13, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4756, 636671889741500000, 7, 1, 14, CAST(1300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4757, 636671889741500000, 7, 2, 14, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4758, 636671889741500000, 7, 3, 14, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4759, 636671889741500000, 7, 4, 14, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4760, 636671889741500000, 7, 5, 14, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4761, 636671889741500000, 7, 6, 14, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4762, 636671889741500000, 7, 7, 14, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4763, 636671889741500000, 7, 8, 14, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4764, 636671889741500000, 7, 9, 14, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4765, 636671889741500000, 7, 1, 15, CAST(1400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4766, 636671889741500000, 7, 2, 15, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4767, 636671889741500000, 7, 3, 15, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4768, 636671889741500000, 7, 4, 15, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4769, 636671889741500000, 7, 5, 15, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4770, 636671889741500000, 7, 6, 15, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4771, 636671889741500000, 7, 7, 15, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4772, 636671889741500000, 7, 8, 15, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4773, 636671889741500000, 7, 9, 15, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:16:14.150' AS DateTime), CAST(N'2018-07-14T18:16:14.153' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4774, 636671890605600000, 6, 1, 1, CAST(0.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4775, 636671890605600000, 6, 2, 1, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4776, 636671890605600000, 6, 3, 1, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4777, 636671890605600000, 6, 4, 1, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4778, 636671890605600000, 6, 5, 1, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4779, 636671890605600000, 6, 1, 2, CAST(100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4780, 636671890605600000, 6, 2, 2, CAST(2000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4781, 636671890605600000, 6, 3, 2, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4782, 636671890605600000, 6, 4, 2, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4783, 636671890605600000, 6, 5, 2, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4784, 636671890605600000, 6, 1, 3, CAST(200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4785, 636671890605600000, 6, 2, 3, CAST(3000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4786, 636671890605600000, 6, 3, 3, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4787, 636671890605600000, 6, 4, 3, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4788, 636671890605600000, 6, 5, 3, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4789, 636671890605600000, 6, 1, 4, CAST(300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4790, 636671890605600000, 6, 2, 4, CAST(4000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4791, 636671890605600000, 6, 3, 4, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4792, 636671890605600000, 6, 4, 4, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4793, 636671890605600000, 6, 5, 4, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4794, 636671890605600000, 6, 1, 5, CAST(400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4795, 636671890605600000, 6, 2, 5, CAST(5000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4796, 636671890605600000, 6, 3, 5, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4797, 636671890605600000, 6, 4, 5, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4798, 636671890605600000, 6, 5, 5, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4799, 636671890605600000, 6, 6, 1, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4800, 636671890605600000, 6, 6, 2, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4801, 636671890605600000, 6, 6, 3, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4802, 636671890605600000, 6, 6, 4, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4803, 636671890605600000, 6, 6, 5, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4804, 636671890605600000, 6, 7, 1, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4805, 636671890605600000, 6, 7, 2, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4806, 636671890605600000, 6, 7, 3, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4807, 636671890605600000, 6, 7, 4, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4808, 636671890605600000, 6, 7, 5, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4809, 636671890605600000, 6, 8, 1, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4810, 636671890605600000, 6, 8, 2, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4811, 636671890605600000, 6, 8, 3, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4812, 636671890605600000, 6, 8, 4, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4813, 636671890605600000, 6, 8, 5, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4814, 636671890605600000, 6, 9, 1, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4815, 636671890605600000, 6, 9, 2, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4816, 636671890605600000, 6, 9, 3, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4817, 636671890605600000, 6, 9, 4, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4818, 636671890605600000, 6, 9, 5, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4819, 636671890605600000, 6, 10, 1, CAST(900.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4820, 636671890605600000, 6, 10, 2, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4821, 636671890605600000, 6, 10, 3, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4822, 636671890605600000, 6, 10, 4, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4823, 636671890605600000, 6, 10, 5, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4824, 636671890605600000, 6, 11, 1, CAST(1000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4825, 636671890605600000, 6, 11, 2, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4826, 636671890605600000, 6, 11, 3, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4827, 636671890605600000, 6, 11, 4, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4828, 636671890605600000, 6, 11, 5, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4829, 636671890605600000, 6, 12, 1, CAST(1100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4830, 636671890605600000, 6, 12, 2, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4831, 636671890605600000, 6, 12, 3, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4832, 636671890605600000, 6, 12, 4, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4833, 636671890605600000, 6, 12, 5, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4834, 636671890605600000, 6, 13, 1, CAST(1200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4835, 636671890605600000, 6, 13, 2, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4836, 636671890605600000, 6, 13, 3, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4837, 636671890605600000, 6, 13, 4, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4838, 636671890605600000, 6, 13, 5, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4839, 636671890605600000, 6, 1, 6, CAST(500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4840, 636671890605600000, 6, 2, 6, CAST(6000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4841, 636671890605600000, 6, 3, 6, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4842, 636671890605600000, 6, 4, 6, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4843, 636671890605600000, 6, 5, 6, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4844, 636671890605600000, 6, 6, 6, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4845, 636671890605600000, 6, 7, 6, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4846, 636671890605600000, 6, 8, 6, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4847, 636671890605600000, 6, 9, 6, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4848, 636671890605600000, 6, 10, 6, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4849, 636671890605600000, 6, 11, 6, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4850, 636671890605600000, 6, 12, 6, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4851, 636671890605600000, 6, 13, 6, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4852, 636671890605600000, 6, 1, 7, CAST(600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4853, 636671890605600000, 6, 2, 7, CAST(7000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4854, 636671890605600000, 6, 3, 7, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4855, 636671890605600000, 6, 4, 7, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4856, 636671890605600000, 6, 5, 7, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4857, 636671890605600000, 6, 6, 7, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4858, 636671890605600000, 6, 7, 7, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4859, 636671890605600000, 6, 8, 7, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4860, 636671890605600000, 6, 9, 7, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4861, 636671890605600000, 6, 10, 7, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4862, 636671890605600000, 6, 11, 7, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4863, 636671890605600000, 6, 12, 7, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4864, 636671890605600000, 6, 13, 7, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4865, 636671890605600000, 6, 1, 8, CAST(700.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4866, 636671890605600000, 6, 2, 8, CAST(8000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4867, 636671890605600000, 6, 3, 8, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4868, 636671890605600000, 6, 4, 8, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4869, 636671890605600000, 6, 5, 8, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4870, 636671890605600000, 6, 6, 8, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4871, 636671890605600000, 6, 7, 8, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4872, 636671890605600000, 6, 8, 8, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4873, 636671890605600000, 6, 9, 8, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4874, 636671890605600000, 6, 10, 8, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4875, 636671890605600000, 6, 11, 8, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4876, 636671890605600000, 6, 12, 8, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4877, 636671890605600000, 6, 13, 8, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4878, 636671890605600000, 6, 1, 9, CAST(800.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4879, 636671890605600000, 6, 2, 9, CAST(9000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4880, 636671890605600000, 6, 3, 9, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4881, 636671890605600000, 6, 4, 9, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4882, 636671890605600000, 6, 5, 9, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4883, 636671890605600000, 6, 6, 9, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4884, 636671890605600000, 6, 7, 9, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4885, 636671890605600000, 6, 8, 9, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4886, 636671890605600000, 6, 9, 9, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4887, 636671890605600000, 6, 10, 9, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4888, 636671890605600000, 6, 11, 9, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4889, 636671890605600000, 6, 12, 9, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4890, 636671890605600000, 6, 13, 9, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4891, 636671890605600000, 6, 1, 10, CAST(900.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4892, 636671890605600000, 6, 2, 10, CAST(10000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4893, 636671890605600000, 6, 3, 10, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4894, 636671890605600000, 6, 4, 10, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4895, 636671890605600000, 6, 5, 10, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4896, 636671890605600000, 6, 6, 10, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4897, 636671890605600000, 6, 7, 10, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4898, 636671890605600000, 6, 8, 10, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4899, 636671890605600000, 6, 9, 10, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4900, 636671890605600000, 6, 10, 10, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4901, 636671890605600000, 6, 11, 10, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4902, 636671890605600000, 6, 12, 10, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4903, 636671890605600000, 6, 13, 10, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4904, 636671890605600000, 6, 1, 11, CAST(1000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4905, 636671890605600000, 6, 2, 11, CAST(11000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4906, 636671890605600000, 6, 3, 11, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4907, 636671890605600000, 6, 4, 11, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4908, 636671890605600000, 6, 5, 11, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4909, 636671890605600000, 6, 6, 11, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4910, 636671890605600000, 6, 7, 11, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4911, 636671890605600000, 6, 8, 11, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4912, 636671890605600000, 6, 9, 11, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4913, 636671890605600000, 6, 10, 11, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4914, 636671890605600000, 6, 11, 11, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4915, 636671890605600000, 6, 12, 11, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4916, 636671890605600000, 6, 13, 11, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4917, 636671890605600000, 6, 1, 12, CAST(1100.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4918, 636671890605600000, 6, 2, 12, CAST(12000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4919, 636671890605600000, 6, 3, 12, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4920, 636671890605600000, 6, 4, 12, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4921, 636671890605600000, 6, 5, 12, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4922, 636671890605600000, 6, 6, 12, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4923, 636671890605600000, 6, 7, 12, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4924, 636671890605600000, 6, 8, 12, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4925, 636671890605600000, 6, 9, 12, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4926, 636671890605600000, 6, 10, 12, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4927, 636671890605600000, 6, 11, 12, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4928, 636671890605600000, 6, 12, 12, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4929, 636671890605600000, 6, 13, 12, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4930, 636671890605600000, 6, 1, 13, CAST(1200.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4931, 636671890605600000, 6, 2, 13, CAST(13000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4932, 636671890605600000, 6, 3, 13, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4933, 636671890605600000, 6, 4, 13, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4934, 636671890605600000, 6, 5, 13, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4935, 636671890605600000, 6, 6, 13, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4936, 636671890605600000, 6, 7, 13, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4937, 636671890605600000, 6, 8, 13, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4938, 636671890605600000, 6, 9, 13, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4939, 636671890605600000, 6, 10, 13, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4940, 636671890605600000, 6, 11, 13, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4941, 636671890605600000, 6, 12, 13, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4942, 636671890605600000, 6, 13, 13, CAST(24000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4943, 636671890605600000, 6, 1, 14, CAST(1300.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4944, 636671890605600000, 6, 2, 14, CAST(14000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4945, 636671890605600000, 6, 3, 14, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4946, 636671890605600000, 6, 4, 14, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4947, 636671890605600000, 6, 5, 14, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4948, 636671890605600000, 6, 6, 14, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4949, 636671890605600000, 6, 7, 14, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4950, 636671890605600000, 6, 8, 14, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4951, 636671890605600000, 6, 9, 14, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4952, 636671890605600000, 6, 10, 14, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4953, 636671890605600000, 6, 11, 14, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4954, 636671890605600000, 6, 12, 14, CAST(24000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4955, 636671890605600000, 6, 13, 14, CAST(25000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4956, 636671890605600000, 6, 1, 15, CAST(1400.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4957, 636671890605600000, 6, 2, 15, CAST(15000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4958, 636671890605600000, 6, 3, 15, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4959, 636671890605600000, 6, 4, 15, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4960, 636671890605600000, 6, 5, 15, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4961, 636671890605600000, 6, 6, 15, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4962, 636671890605600000, 6, 7, 15, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4963, 636671890605600000, 6, 8, 15, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4964, 636671890605600000, 6, 9, 15, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4965, 636671890605600000, 6, 10, 15, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4966, 636671890605600000, 6, 11, 15, CAST(24000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4967, 636671890605600000, 6, 12, 15, CAST(25000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4968, 636671890605600000, 6, 13, 15, CAST(26000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4969, 636671890605600000, 6, 1, 16, CAST(1500.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4970, 636671890605600000, 6, 2, 16, CAST(16000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4971, 636671890605600000, 6, 3, 16, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4972, 636671890605600000, 6, 4, 16, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4973, 636671890605600000, 6, 5, 16, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4974, 636671890605600000, 6, 6, 16, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4975, 636671890605600000, 6, 7, 16, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4976, 636671890605600000, 6, 8, 16, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4977, 636671890605600000, 6, 9, 16, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4978, 636671890605600000, 6, 10, 16, CAST(24000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4979, 636671890605600000, 6, 11, 16, CAST(25000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4980, 636671890605600000, 6, 12, 16, CAST(26000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4981, 636671890605600000, 6, 13, 16, CAST(27000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4982, 636671890605600000, 6, 1, 17, CAST(1600.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4983, 636671890605600000, 6, 2, 17, CAST(17000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4984, 636671890605600000, 6, 3, 17, CAST(18000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4985, 636671890605600000, 6, 4, 17, CAST(19000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4986, 636671890605600000, 6, 5, 17, CAST(20000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4987, 636671890605600000, 6, 6, 17, CAST(21000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4988, 636671890605600000, 6, 7, 17, CAST(22000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4989, 636671890605600000, 6, 8, 17, CAST(23000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4990, 636671890605600000, 6, 9, 17, CAST(24000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4991, 636671890605600000, 6, 10, 17, CAST(25000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4992, 636671890605600000, 6, 11, 17, CAST(26000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4993, 636671890605600000, 6, 12, 17, CAST(27000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [GroupId], [ProductMaterialId], [Row], [Column], [Value], [IsActive], [PriceType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4994, 636671890605600000, 6, 13, 17, CAST(28000.00 AS Decimal(18, 2)), 1, 2, NULL, NULL, CAST(N'2018-07-14T18:17:40.560' AS DateTime), CAST(N'2018-07-14T18:17:40.563' AS DateTime))
SET IDENTITY_INSERT [dbo].[ProductPrice] OFF
INSERT [dbo].[SEC_User] ([RecId], [UserName], [FirstName], [LastName], [FullName], [Password], [Email], [Birthday], [Age], [Sex], [Address], [City], [State], [PhoneNumber], [CreateDTS], [UpdateDTS], [LastLoginDTS], [CreateBy], [ActiveStatus], [Locked], [UpdateBy]) VALUES (N'FCF88E68-CEE2-4020-8C40-8A4D22A73F39', N'tung', N'tug', N'le', NULL, N'tung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-11T21:14:35.510' AS DateTime), NULL, NULL, NULL, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Supplier] ON 

INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ABN], [IsBWC], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'tung', N'le', N'aperia', N'mngo@aperia.com', NULL, NULL, NULL, N'quoturm', NULL, N'dallas', N'TEXAS', NULL, NULL, NULL, N'12345689', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-12T21:55:26.153' AS DateTime), NULL)
INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ABN], [IsBWC], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'viet', N'tuan', N'CSC', N'mngo@aperia.com', NULL, NULL, N'this is note', N'quoturm', NULL, N'dallas', N'TEXAS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-13T23:51:43.300' AS DateTime), NULL)
INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ABN], [IsBWC], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, N'Thanh', N'Nguyen', N'BWC Company', N'tungle@aperia.com', N'dev', NULL, NULL, N'123 Syney Australia', NULL, N'dong nai', NULL, NULL, N'123456', NULL, N'123456', NULL, N'123abn', NULL, NULL, NULL, NULL, CAST(N'2018-06-14T00:21:42.507' AS DateTime), CAST(N'2018-07-14T14:11:07.417' AS DateTime))
SET IDENTITY_INSERT [dbo].[Supplier] OFF
SET ANSI_PADDING ON
GO
/****** Object:  Index [PK_SEC_Admin]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_AuthenticateUser]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_CalculateOrderAmount]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec sp_CalculateOrderAmount @OrderId=1

CREATE PROCEDURE [dbo].[sp_CalculateOrderAmount]
	@OrderId BIGINT
AS
BEGIN	
	DECLARE @TotalPaid DECIMAL(18,2),
			@TotalReceived DECIMAL(18,2),
			@TotalAmount DECIMAL(18,2),
			@Balance DECIMAL(18,2)

	CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2), TotalReceived DECIMAL(18,2))

	INSERT INTO #OrderSummary
	SELECT 
		tb.OrderId, 
		SUM(tb.TotalAmount) AS TotalAmount,
		SUM(tb.TotalReceived) AS TotalReceived
	FROM (
			SELECT 
				op.OrderId AS OrderId,
				op.Quantity * (op.ExtendPrice + op.UnitPrice) AS TotalAmount,
				op.Received * (op.ExtendPrice + op.UnitPrice)  AS TotalReceived
			FROM [Order] o WITH(NOLOCK)	
				join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
			WHERE o.Id =  @OrderId
			UNION ALL
			SELECT 
				op.OrderId AS OrderId,
				op.Quantity * c.Price AS TotalAmount,
				op.Received  * c.Price AS TotalReceived
			 FROM [Order] o WITH(NOLOCK)	
				join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
				join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
			WHERE o.Id =  @OrderId
		) AS tb
	GROUP BY tb.OrderId

	SELECT 
		@TotalAmount = (ISNULL(os.TotalAmount,0) * o.Taxes/100) + ISNULL(os.TotalAmount,0),
		@TotalReceived = (ISNULL(os.TotalReceived,0) * o.Taxes/100) + ISNULL(os.TotalReceived,0)
	FROM [Order] o WITH(NOLOCK)
		LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId
	WHERE o.Id =  @OrderId


	SELECT  @TotalPaid = ISNULL(SUM(op.AmountPaid),0)
	FROM  OrderPayment op WITH(NOLOCK)
	WHERE op.OrderId = @OrderId
	GROUP BY op.OrderId

	UPDATE [Order]
	SET TotalAmount = @TotalAmount
	,	TotalReceived = @TotalReceived
	,	TotalPaid	= @TotalPaid
	,	Balance = @TotalReceived - @TotalPaid
    WHERE Id = @OrderId


	DROP TABLE #OrderSummary
END




GO
/****** Object:  StoredProcedure [dbo].[sp_CopyOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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

	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@NewId
END




GO
/****** Object:  StoredProcedure [dbo].[sp_CopyProductMaterialPrice]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_CopyProductMaterialPrice]

CREATE PROCEDURE [dbo].[sp_CopyProductMaterialPrice]
	@ProductMaterialId INT,
	@PriceType INT
AS
BEGIN	
	DECLARE @CurrentDTS DATETIME,
			@GroupId BIGINT
	SELECT @CurrentDTS = GETDATE()
			,@GroupId = [dbo].ToTicks(@CurrentDTS)

	--copy order info
	INSERT INTO ProductPrice(ProductMaterialId,[Row],[Column],[Value],UpdateDTS,CreateDTS,IsActive,GroupId,PriceType)
	SELECT @ProductMaterialId,[Row],[Column],[Value],@CurrentDTS,@CurrentDTS,1,@GroupId,PriceType
	FROM ProductPrice WITH(NOLOCK)
	WHERE ProductMaterialId = @ProductMaterialId 
	AND IsActive = 1
	AND PriceType = @PriceType

	UPDATE ProductPrice
	SET IsActive = 0
	WHERE ProductMaterialId = @ProductMaterialId 
	AND GroupId <> @GroupId
	AND PriceType = @PriceType

END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteCustomer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteCustomer] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteCustomer]
	@Id INT
AS
BEGIN	
	DELETE Customer	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	DECLARE @OrderId BIGINT

	SELECT  @OrderId = @OrderId
	FROM OrderComponent WITH(NOLOCK)
	WHERE Id = @Id

	DELETE OrderComponent
	WHERE Id =  @Id
    
	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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

CREATE PROCEDURE [dbo].[sp_DeleteOrderPayment]
	@Id INT
AS
BEGIN	    
	DECLARE @OrderId BIGINT

	SELECT  @OrderId = @OrderId
	FROM OrderPayment WITH(NOLOCK)
	WHERE Id = @Id

	DELETE OrderPayment
	WHERE Id =  @Id

	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	DECLARE @OrderId BIGINT

	SELECT  @OrderId = @OrderId
	FROM OrderPayment WITH(NOLOCK)
	WHERE Id = @Id

	DELETE OrderProduct
	WHERE Id =  @Id
	
	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteProductMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteSupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllColor]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	SELECT c.*, s.Company AS SupplierName
	FROM Component c WITH(NOLOCK)
	LEFT JOIN Supplier s WITH(NOLOCK) ON c.SupplierId = s.Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllComponentBySupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	WHERE s.Id = @Id OR @Id = 0
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllCustomer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllCustomer]

CREATE PROCEDURE [dbo].[sp_GetAllCustomer]
	
AS
BEGIN	
	SELECT * FROM Customer WITH(NOLOCK)	
    ORDER BY IsBWC DESC, Id DESC
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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

CREATE PROCEDURE [dbo].[sp_GetAllMaterial]
	
AS
BEGIN	
	SELECT c.*, s.Company AS SupplierName
	FROM Material c WITH(NOLOCK)
	LEFT JOIN Supplier s WITH(NOLOCK) ON c.SupplierId = s.Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	--CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2),TotalReceived DECIMAL(18,2))
	--CREATE TABLE #ProcessSummary(OrderId BIGINT, PaymentAmount DECIMAL(18,2), InvoiceAmount DECIMAL(18,2))

	--INSERT INTO #OrderSummary
	--SELECT tb.OrderId, ISNULL(SUM(tb.TotalAmount),0) AS TotalAmount ,ISNULL(SUM(tb.TotalReceived),0) AS TotalReceived
	--FROM (
	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * (op.ExtendPrice + op.UnitPrice) AS TotalAmount,
	--			op.Received * (op.ExtendPrice + op.UnitPrice) AS TotalReceived
	--		FROM [Order] o WITH(NOLOCK)	
	--			join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
	--		WHERE o.OrderType=@OrderType

	--		UNION ALL

	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * c.Price AS TotalAmount,
	--			op.Received * c.Price AS TotalReceived
	--		 FROM [Order] o WITH(NOLOCK)	
	--			join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
	--			join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
	--		WHERE o.OrderType=@OrderType
	--	) AS tb
	--GROUP BY tb.OrderId

	--INSERT INTO #ProcessSummary
	--SELECT 
	--	ps.OrderId AS OrderId
	--	, ISNULL(SUM(ps.PaymentAmount),0) AS PaymentAmount
	--	, ISNULL(SUM(ps.InvoiceAmount),0) AS InvoiceAmount
	--FROM(
	--	SELECT o.Id AS OrderId
	--	, ISNULL(SUM(op.AmountPaid),0) AS PaymentAmount
	--	, 0 AS InvoiceAmount
	--	FROM [Order] o WITH(NOLOCK)
	--		INNER JOIN OrderPayment op WITH(NOLOCK) ON o.Id = op.OrderId
	--	WHERE OrderType=@OrderType
	--	GROUP BY o.Id
	--	UNION ALL
	--	SELECT o.Id AS OrderId
	--	, 0 AS PaymentAmount
	--	, ISNULL(SUM(oi.InvoiceAmount),0) AS InvoiceAmount
	--	FROM [Order] o WITH(NOLOCK)
	--		INNER JOIN OrderInvoice oi WITH(NOLOCK) ON o.Id = oi.OrderId
	--	WHERE OrderType=@OrderType
	--	GROUP BY o.Id
	--) ps
	--GROUP BY ps.OrderId

	--SELECT o.*
	--,(os.TotalAmount * ISNULL(o.Taxes,0)/100) + os.TotalAmount AS  TotalAmount
	--,(os.TotalReceived * ISNULL(o.Taxes,0)/100) + os.TotalReceived AS  TotalReceived
	----, ISNULL(os.TotalAmount,0) AS  TotalAmount
	--, ISNULL(ps.PaymentAmount,0) AS PaymentAmount
	--, ISNULL(ps.InvoiceAmount,0) AS InvoiceAmount
	--, ISNULL((os.TotalAmount * ISNULL(o.Taxes,0)/100) + os.TotalAmount,0) - ISNULL(ps.PaymentAmount,0) AS  Balance
	--FROM [Order] o WITH(NOLOCK)
	--LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId	
	--LEFT JOIN #ProcessSummary ps WITH(NOLOCK) ON o.Id = ps.OrderId
 --   WHERE OrderType=@OrderType
	--ORDER BY o.Id DESC
	CREATE TABLE #OrderPayment (OrderId BIGINT, DatePaid DATETIME)

	INSERT #OrderPayment
	SELECT OrderId ,MAX(DatePaid)
	FROM OrderPayment WITH(NOLOCK)
	GROUP BY OrderId


	SELECT o.*,op.DatePaid
	FROM [Order] o WITH(NOLOCK)
		LEFT JOIN #OrderPayment op WITH(NOLOCK) ON op.OrderId = o.Id
    WHERE OrderType=@OrderType
	ORDER BY o.Id DESC
	
	DROP TABLE #OrderPayment
	--DROP TABLE #ProcessSummary
	--DROP TABLE #OrderSummary
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderByDateRange]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrderByDateRange] @OrderType=1

CREATE PROCEDURE [dbo].[sp_GetAllOrderByDateRange]
	@OrderType INT,
	@From DATETIME,
	@To DATETIME
AS
BEGIN	
	--CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2),TotalReceived DECIMAL(18,2))
	--CREATE TABLE #ProcessSummary(OrderId BIGINT, PaymentAmount DECIMAL(18,2), InvoiceAmount DECIMAL(18,2))

	--INSERT INTO #OrderSummary
	--SELECT tb.OrderId, ISNULL(SUM(tb.TotalAmount),0) AS TotalAmount ,ISNULL(SUM(tb.TotalReceived),0) AS TotalReceived
	--FROM (
	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * (op.ExtendPrice + op.UnitPrice) AS TotalAmount,
	--			op.Received * (op.ExtendPrice + op.UnitPrice) AS TotalReceived
	--		FROM [Order] o WITH(NOLOCK)	
	--			join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
	--		WHERE o.OrderType=@OrderType
	--			AND OrderDate between @From and @To

	--		UNION ALL

	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * c.Price AS TotalAmount,
	--			op.Received * c.Price AS TotalReceived
	--		 FROM [Order] o WITH(NOLOCK)	
	--			join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
	--			join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
	--		WHERE o.OrderType=@OrderType
	--			AND OrderDate between @From and @To
	--	) AS tb
	--GROUP BY tb.OrderId

	--INSERT INTO #ProcessSummary
	--SELECT 
	--	ps.OrderId AS OrderId
	--	, ISNULL(SUM(ps.PaymentAmount),0) AS PaymentAmount
	--	, ISNULL(SUM(ps.InvoiceAmount),0) AS InvoiceAmount
	--FROM(
	--	SELECT o.Id AS OrderId
	--		, ISNULL(SUM(op.AmountPaid),0) AS PaymentAmount
	--		, 0 AS InvoiceAmount
	--	FROM [Order] o WITH(NOLOCK)
	--		INNER JOIN OrderPayment op WITH(NOLOCK) ON o.Id = op.OrderId
	--	WHERE OrderType=@OrderType
	--		AND OrderDate between @From and @To
	--	GROUP BY o.Id

	--	UNION ALL

	--	SELECT o.Id AS OrderId
	--		, 0 AS PaymentAmount
	--		, ISNULL(SUM(oi.InvoiceAmount),0) AS InvoiceAmount
	--	FROM [Order] o WITH(NOLOCK)
	--		INNER JOIN OrderInvoice oi WITH(NOLOCK) ON o.Id = oi.OrderId
	--	WHERE OrderType=@OrderType
	--		AND OrderDate between @From and @To
	--	GROUP BY o.Id
	--) ps
	--GROUP BY ps.OrderId

	--SELECT o.*
	--	, (os.TotalAmount * ISNULL(o.Taxes,0)/100) + os.TotalAmount AS  TotalAmount
	--	,(os.TotalReceived * ISNULL(o.Taxes,0)/100) + os.TotalReceived AS  TotalReceived
	--	, ISNULL(ps.PaymentAmount,0) AS PaymentAmount
	--	, ISNULL(ps.InvoiceAmount,0) AS InvoiceAmount
	--FROM [Order] o WITH(NOLOCK)
	--	LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId	
	--	LEFT JOIN #ProcessSummary ps WITH(NOLOCK) ON o.Id = ps.OrderId
 --   WHERE OrderType=@OrderType
	--	AND OrderDate between @From and @To
	--ORDER BY o.Id DESC

	--DROP TABLE #ProcessSummary
	--DROP TABLE #OrderSummary

	SELECT o.*
	FROM [Order] o WITH(NOLOCK)
    WHERE OrderType=@OrderType
		AND OrderDate between @From and @To
	ORDER BY o.Id DESC
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	,p.Description AS [Description]
	FROM OrderComponent pc WITH(NOLOCK)	
	JOIN Component p WITH(NOLOCK)ON pc.ComponentId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.OrderId = @OrderId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	INNER JOIN Material m WITH(NOLOCK)ON pm.MaterialId = m.Id
	WHERE pm.ProductId = @Productid
    ORDER BY pm.Id DESC
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductPrice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@ProductId INT,
	@PriceType INT
AS
BEGIN	
	SELECT pp.*
		, pm.MaterialId AS MaterialId
		, pm.ProductId AS ProductId
		, pm.Id AS Id
	FROM ProductPrice pp WITH(NOLOCK)
		INNER JOIN ProductMaterial pm WITH(NOLOCK) ON pp.ProductMaterialId = pm.Id
	WHERE pm.ProductId= @ProductId AND IsActive = 1 AND PriceType=@PriceType
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductPriceByGroup]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllProductPriceByGroup] @GroupId= 636655461680130000

CREATE PROCEDURE [dbo].[sp_GetAllProductPriceByGroup]
	@GroupId BIGINT,
	@PriceType INT
AS
BEGIN	
	SELECT pp.*, pm.MaterialId AS MaterialId,pm.ProductId AS ProductId
	FROM ProductPrice pp WITH(NOLOCK)
	JOIN ProductMaterial pm WITH(NOLOCK) ON pp.ProductMaterialId = pm.Id
	WHERE pp.GroupId= @GroupId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllSupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetCustomer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetCustomer]

CREATE PROCEDURE [dbo].[sp_GetCustomer]
	@Id INT
AS
BEGIN	
	SELECT * FROM Customer WITH(NOLOCK)	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemsInOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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
		op.UnitId AS UnitId,
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
		op.UnitId AS UnitId,
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
/****** Object:  StoredProcedure [dbo].[sp_GetListGroupPriceByProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetListGroupPriceByProduct] @ProductMaterialId= 6

CREATE PROCEDURE [dbo].[sp_GetListGroupPriceByProduct]
	@ProductMaterialId INT,
	@PriceType INT
AS
BEGIN	
	SELECT DISTINCT GroupId,ProductMaterialId,CreateDTS,UpdateDTS,IsActive
	FROM ProductPrice WITH(NOLOCK)
	WHERE ProductMaterialId= @ProductMaterialId AND PriceType = @PriceType
    ORDER BY GroupId DESC
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrder] @Id=1530360334538

CREATE PROCEDURE [dbo].[sp_GetOrder]
	@Id BIGINT,
	@OrderType INT=1
AS
BEGIN	
	--CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2), TotalReceived DECIMAL(18,2))

	--INSERT INTO #OrderSummary
	--SELECT tb.OrderId, 
	--SUM(tb.TotalAmount) AS TotalAmount,
	--SUM(tb.TotalReceived) AS TotalReceived
	--FROM (
	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * (op.ExtendPrice + op.UnitPrice) AS TotalAmount,
	--			op.Received * (op.ExtendPrice + op.UnitPrice)  AS TotalReceived
	--		FROM [Order] o WITH(NOLOCK)	
	--			join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
	--		WHERE o.Id =  @Id
	--		UNION ALL
	--		SELECT 
	--			op.OrderId AS OrderId,
	--			op.Quantity * c.Price AS TotalAmount,
	--			op.Received  * c.Price AS TotalReceived
	--		 FROM [Order] o WITH(NOLOCK)	
	--			join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
	--			join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
	--		WHERE o.Id =  @Id
	--	) AS tb
	--GROUP BY tb.OrderId

	--SELECT o.*, 
	--(ISNULL(os.TotalAmount,0) * o.Taxes/100) + ISNULL(os.TotalAmount,0) AS  TotalAmount,
	--(ISNULL(os.TotalReceived,0) * o.Taxes/100) + ISNULL(os.TotalReceived,0) AS  TotalReceived
	--FROM [Order] o WITH(NOLOCK)
	--LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId
	--WHERE o.Id =  @Id
    
	--DROP TABLE #OrderSummary

	SELECT o.*
	FROM [Order] o WITH(NOLOCK)
	WHERE o.Id =  @Id
END



GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetOrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetOrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetOrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GetProductMaterialPrice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@ProductMaterialId INT,
	@PriceType INT
AS
BEGIN	
	SELECT * 
	FROM ProductPrice WITH(NOLOCK)
	WHERE ProductMaterialId= @ProductMaterialId AND IsActive = 1 AND PriceType = @PriceType
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetSupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_InsertComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@PurchasePrice DECIMAL(18,2),
    @Color NVARCHAR(250),
    @Unit NVARCHAR(250),
    @Description  NVARCHAR(MAX),
	@Discount DECIMAL(18,2),
    @ActiveStatus INT
AS
BEGIN	
	INSERT Component(
		ComponentCode,
		ComponentName,
		SupplierId,
		Price,
		PurchasePrice,
		Color,
		Unit,
		Description,
		Discount,
		ActiveStatus,
        CreateDTS)
	SELECT 
        @ComponentCode,
		@ComponentName,
		@SupplierId,
		@Price,
		@PurchasePrice,
		@Color,
		@Unit,
		@Description,
		@Discount,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertCustomer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertCustomer]

CREATE PROCEDURE [dbo].[sp_InsertCustomer]
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
    @Fax NVARCHAR(250),
	@Discount DECIMAL(18,2),
	@ABN NVARCHAR(250)
AS
BEGIN	
	INSERT Customer(
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
		Discount,
		ABN,
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
		@Discount,
		@ABN,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
    @MaterialCode NVARCHAR(250),
	@MaterialName NVARCHAR(250),
	@Color NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Description NVARCHAR(MAX), 
    @ActiveStatus INT
AS
BEGIN	
	INSERT Material(
		MaterialCode,
		MaterialName,		
		SupplierId,
		Price,
		Description,
		ActiveStatus,
		Color,
        CreateDTS)
	SELECT 
		@MaterialCode,
		@MaterialName,
		@SupplierId,
		@Price,
		@Description,
		@ActiveStatus,
		@Color,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@DeliveryNo NVARCHAR(250),
    @Notes NVARCHAR(MAX),
    @SupplierId INT,
    @SupplierName NVARCHAR(500),
    @SupplierAddress NVARCHAR(500),
    @SupplierEmail NVARCHAR(250),
    @SupplierPhone NVARCHAR(250),	
	@CustomerId INT,
    @CustomerName NVARCHAR(500),
    @CustomerAddress NVARCHAR(500),
    @CustomerEmail NVARCHAR(250),
    @CustomerPhone NVARCHAR(250),
    @OrderRefNo NVARCHAR(250),
    @OrderType INT,
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
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
		DeliveryNo,	
		Notes,
		SupplierId,
		SupplierName,
		SupplierAddress,
		SupplierEmail,
		SupplierPhone,
		CustomerId,
		CustomerName,
		CustomerAddress,
		CustomerEmail,
		CustomerPhone,
		OrderRefNo,
		OrderType,
		AMTExcGST,
		GST,
		AMTIncGST,
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
		GETDATE(),
		@FirtReceiveDate,
		@LastUpdate,
		@DeliveryDate,		
		@DeliveryNo,
		@Notes,
		@SupplierId,
		@SupplierName,
		@SupplierAddress,
		@SupplierEmail,
		@SupplierPhone,
		@CustomerId,
		@CustomerName,
		@CustomerAddress,
		@CustomerEmail,
		@CustomerPhone,
		@OrderRefNo,
		@OrderType,
		@AMTExcGST,
		@GST,
		@AMTIncGST,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
    
	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
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
		AMTExcGST,
		GST,
		AMTIncGST,
		CreateDTS)
	SELECT 
        @OrderId,
		@InvoiceNo,
		GETDATE(),
		@InvoiceAmount,
		@CutLengthCharge,
		@DeliveryCharge,
		@AMTExcGST,
		@GST,
		@AMTIncGST,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@DatePaid DATETIME,
	@ActiveStatus INT
AS
BEGIN	

	DECLARE @TotalPaid DECIMAL(18,2),
			@TotalReceived DECIMAL(18,2)
	-- Step 1: insert
	INSERT OrderPayment(
		OrderId,
		DatePaid,
		AmountPaid,
		PaymentType,
		CreateDTS)
	SELECT 
        @OrderId,
		@DatePaid,
		@AmountPaid,
		@PaymentType,
        GETDATE()

	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId

	-- Step 3: change order step
	SELECT @TotalPaid = TotalPaid
	,	@TotalReceived = TotalReceived
	FROM [Order]
	WHERE Id = @OrderId

	IF(@TotalPaid - @TotalReceived >= 0)
	BEGIN
		UPDATE [Order]
		SET Step = 5 --PAID
		WHERE Id = @OrderId
	END
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@ColorName NVARCHAR(250),
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
		ColorName,
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
		@ColorName,
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
    -- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_InsertProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_InsertProductMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_InsertSupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
    @Fax NVARCHAR(250),
	@ABN NVARCHAR(250)
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
		ABN,
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
		@ABN,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@PurchasePrice DECIMAL(18,2),
    @Color NVARCHAR(250),
    @Unit NVARCHAR(250),
    @Description  NVARCHAR(MAX),
	@Discount DECIMAL(18,2),
    @ActiveStatus INT
AS
BEGIN	
	UPDATE Component
	SET ComponentCode=ISNULL(@ComponentCode,ComponentCode),
        ComponentName=ISNULL(@ComponentName,ComponentName),
        SupplierId=ISNULL(@SupplierId,SupplierId),
        Price=ISNULL(@Price,Price),
		PurchasePrice=ISNULL(@PurchasePrice,PurchasePrice),
        Color=ISNULL(@Color,Color),
        Unit=ISNULL(@Unit,Unit),
        Description=ISNULL(@Description,Description),
		Discount=ISNULL(@Discount,Discount),
        ActiveStatus=ISNULL(@ActiveStatus,ActiveStatus),
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateCustomer]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateCustomer]

CREATE PROCEDURE [dbo].[sp_UpdateCustomer]
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
    @Fax NVARCHAR(250),
	@Discount DECIMAL(18,2),
	@ABN NVARCHAR(250)
AS
BEGIN	
	UPDATE Customer
	SET 
        FirstName=ISNULL(@FirstName,FirstName),
        LastName=ISNULL(@LastName,LastName),
        Company=ISNULL(@Company,Company),
        Email=ISNULL(@Email,Email),
        JobTitle=ISNULL(@JobTitle,JobTitle),
        WebPage=ISNULL(@WebPage,WebPage),
        Notes=ISNULL(@Notes,Notes),
        Address=ISNULL(@Address,Address),
        ZipCode=ISNULL(@ZipCode,ZipCode),
        City=ISNULL(@City,City),
        State=ISNULL(@State,State),
        Country=ISNULL(@Country,Country),
        BusinessPhone=ISNULL(@BusinessPhone,BusinessPhone),
        MobilePhone=ISNULL(@MobilePhone,MobilePhone),
        HomePhone=ISNULL(@HomePhone,HomePhone),
        Fax=ISNULL(@Fax,Fax),
		Discount=ISNULL(@Discount,Discount),
		ABN=ISNULL(@ABN,ABN),
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateMaterial]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@MaterialCode NVARCHAR(250),
    @MaterialName NVARCHAR(250),
	@Color NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Description NVARCHAR(MAX), 
    @ActiveStatus INT
AS
BEGIN	
	UPDATE Material
	SET MaterialCode=ISNULL(@MaterialCode,MaterialCode),
		MaterialName=ISNULL(@MaterialName,MaterialName),
        SupplierId=ISNULL(@SupplierId,SupplierId),
        Price=ISNULL(@Price,Price),
        Description=ISNULL(@Description, Description),                                   
        ActiveStatus=ISNULL(@ActiveStatus,ActiveStatus),
		Color=ISNULL(@Color,Color),
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrder]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@DeliveryNo NVARCHAR(250),
    @Notes NVARCHAR(MAX),
    @SupplierId INT,
    @SupplierName NVARCHAR(500),
    @SupplierAddress NVARCHAR(500),
    @SupplierEmail NVARCHAR(250),
    @SupplierPhone NVARCHAR(250),
	@CustomerId INT,
    @CustomerName NVARCHAR(500),
    @CustomerAddress NVARCHAR(500),
    @CustomerEmail NVARCHAR(250),
    @CustomerPhone NVARCHAR(250),
    @OrderRefNo NVARCHAR(250),
    @OrderType INT,
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
    @ActiveStatus INT
AS
BEGIN	
	UPDATE [Order]
	SET EmployeeId=ISNULL(@EmployeeId,EmployeeId),
		EmployeeName =ISNULL(@EmployeeName,EmployeeName),
		Step=ISNULL(@Step,Step),
		Taxes=ISNULL(@Taxes,Taxes),
        Surcharge=ISNULL(@Surcharge,Surcharge),
        Discount=ISNULL(@Discount,Discount),
        --OrderDate=ISNULL(@OrderDate,OrderDate),
        FirtReceiveDate=ISNULL(@FirtReceiveDate,FirtReceiveDate),
        LastUpdate=ISNULL(@LastUpdate,LastUpdate),
        DeliveryDate=ISNULL(@DeliveryDate,DeliveryDate),
		DeliveryNo=ISNULL(@DeliveryNo,DeliveryNo),
        Notes=ISNULL(@Notes,Notes),
        SupplierId=ISNULL(@SupplierId,SupplierId),
        SupplierName=ISNULL(@SupplierName,SupplierName),
        SupplierAddress=ISNULL(@SupplierAddress,SupplierAddress),
        SupplierEmail=ISNULL(@SupplierEmail,SupplierEmail),
        SupplierPhone=ISNULL(@SupplierPhone,SupplierPhone),
		CustomerId=ISNULL(@CustomerId,CustomerId),
        CustomerName=ISNULL(@CustomerName,CustomerName),
        CustomerAddress=ISNULL(@CustomerAddress,CustomerAddress),
        CustomerEmail=ISNULL(@CustomerEmail,CustomerEmail),
        CustomerPhone=ISNULL(@CustomerPhone,CustomerPhone),
        OrderRefNo=ISNULL(@OrderRefNo,OrderRefNo),
        OrderType=ISNULL(@OrderType,@OrderType),
		AMTExcGST=ISNULL(@AMTExcGST,AMTExcGST),
		GST=ISNULL(@GST,GST),
		AMTIncGST=ISNULL(@AMTIncGST,AMTIncGST),
        ActiveStatus=ISNULL(@ActiveStatus,ActiveStatus),
        UpdateDts=GETDATE()
    WHERE Id=@Id
    
END
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
/*
 exec [sp_UpdateOrderComponent] @Id =24,@OrderId=null, @ComponentId=null, @ColorId=1, @Quantity =null
,@Price =null, @ExtCharge =null, @UnitId =null,	@Step=null,@TotalAmount=null,@DeliveryNo =null,@DeliveryDate=null
,@Received=null,@BackOrder=null,@AMTExcGST=null,@GST=null,@AMTIncGST=null,@ReceivedAMTExcGST=null,@ReceivedGST=null,@ReceivedAMTIncGST =null
*/
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
	DECLARE @OdId BIGINT

	UPDATE OrderComponent
	SET
        OrderId=ISNULL(@OrderId,OrderId),
		ComponentId=ISNULL(@ComponentId,ComponentId),
		ColorId=ISNULL(@ColorId,ColorId),
		Quantity=ISNULL(@Quantity,Quantity),
		Price=ISNULL(@Price,Price),
		ExtCharge=ISNULL(@ExtCharge,ExtCharge),
		UnitId=ISNULL(@UnitId,UnitId),
		Step=ISNULL(@Step,Step),
		TotalAmount =ISNULL(@TotalAmount,TotalAmount),
		DeliveryNo =ISNULL(@DeliveryNo,DeliveryNo),
		DeliveryDate =ISNULL(@DeliveryDate,DeliveryDate),
		Received =ISNULL(@Received,Received),
		BackOrder =ISNULL(@BackOrder,BackOrder),
		AMTExcGST=ISNULL(@AMTExcGST,AMTExcGST),
		GST=ISNULL(@GST,GST),
		AMTIncGST=ISNULL(@AMTIncGST,AMTIncGST),
		ReceivedAMTExcGST=ISNULL(@ReceivedAMTExcGST,ReceivedAMTExcGST),
		ReceivedGST=ISNULL(@ReceivedGST,ReceivedGST),
		ReceivedAMTIncGST=ISNULL(@ReceivedAMTIncGST,ReceivedAMTIncGST),
        UpdateDTS = GETDATE()
    WHERE
		Id = @Id

	SELECT @OdId = OrderId FROM OrderComponent WITH(NOLOCK)
	WHERE Id = @Id

	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OdId
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderInvoice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
	@ActiveStatus INT
AS
BEGIN	
	UPDATE OrderInvoice
	SET
        OrderId=ISNULL(@OrderId,OrderId),
		InvoiceNo=ISNULL(@InvoiceNo,InvoiceNo),
		InvoiceAmount=ISNULL(@InvoiceAmount,InvoiceAmount),
		CutLengthCharge=ISNULL(@CutLengthCharge,CutLengthCharge),
		DeliveryCharge=ISNULL(@DeliveryCharge,DeliveryCharge),
		AMTExcGST=ISNULL(@AMTExcGST,AMTExcGST),
		GST=ISNULL(@GST,GST),
		AMTIncGST=ISNULL(@AMTIncGST,AMTIncGST),
        ActiveStatus=ISNULL(@ActiveStatus,ActiveStatus),
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderListComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrderListComponent]

CREATE PROCEDURE [dbo].[sp_UpdateOrderListComponent]
	@OrderId BIGINT,	
    @Xml XML
AS
BEGIN	
	IF OBJECT_ID('tempdb..#XMLColumns') IS NOT NULL
	DROP TABLE #XMLColumns

	SELECT x.value('Id[1]', 'INT') AS ComponentId
	,x.value('Quantity[1]', 'INT') AS Quantity
	,x.value('Price[1]', 'DECIMAL(18,2)') AS Price
	,x.value('Discount[1]', 'DECIMAL(18,2)') AS Discount
	INTO #XMLColumns
	FROM @Xml.nodes('/ArrayOfComponent/Component') TempXML (x)
	
	-- step 1: delete all component of order
	DELETE OrderComponent
	WHERE OrderId=@OrderId
	
	-- step 2: insert new components into order
	INSERT INTO OrderComponent(OrderId,ComponentId,ColorName,Price,UnitName,TotalAmount, Quantity, Discount, CreateDTS)
	SELECT @OrderId,ComponentId,c.Color,t.Price,c.Unit,(t.Price - (t.Price * t.Discount/100)) * t.Quantity,t.Quantity,t.Discount, GETDATE()
	FROM #XMLColumns t
	JOIN Component c WITH(NOLOCK) ON t.ComponentId = c.Id
    
	-- Step 3: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId
END



GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderPayment]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@DatePaid DATETIME,
	@ActiveStatus INT
AS
BEGIN	

	DECLARE @TotalPaid DECIMAL(18,2),
			@TotalReceived DECIMAL(18,2)
	-- Step 1: insert
	UPDATE OrderPayment
	SET
        OrderId=ISNULL(@OrderId,OrderId),
		AmountPaid=ISNULL(@AmountPaid,AmountPaid),
		PaymentType=ISNULL(@PaymentType,PaymentType),
		DatePaid=ISNULL(@DatePaid,DatePaid),
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
	-- Step 2: update amount
	EXEC sp_CalculateOrderAmount @OrderId=@OrderId

	-- Step 3: change order step
	SELECT @TotalPaid = TotalPaid
	,	@TotalReceived = TotalReceived
	FROM [Order]
	WHERE Id = @OrderId

	IF(@TotalPaid - @TotalReceived >= 0)
	BEGIN
		UPDATE [Order]
		SET Step = 5 --PAID
		WHERE Id = @OrderId
	END

	-- Change order step to PAID if total amoun paid equal or greater total amount recieved

		--SELECT  @TotalPaid = ISNULL(SUM(op.AmountPaid),0)
		--FROM  OrderPayment op WITH(NOLOCK)
		--WHERE op.OrderId = @OrderId
		--GROUP BY op.OrderId

		--SELECT @TotalRecieved =  ISNULL(SUM(tb.TotalReceived),0)
		--FROM (
		--		SELECT 
		--			op.OrderId AS OrderId,
		--			op.Received * (op.ExtendPrice + op.UnitPrice) AS TotalReceived
		--		FROM OrderProduct op WITH(NOLOCK)
		--		WHERE op.OrderId = @OrderId

		--		UNION ALL

		--		SELECT 
		--			op.OrderId AS OrderId,
		--			op.Received * c.Price AS TotalReceived
		--		 FROM OrderComponent op WITH(NOLOCK)
		--			join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
		--		WHERE op.OrderId = @OrderId
		--	) AS tb
		--GROUP BY tb.OrderId

		--IF(@TotalPaid - @TotalRecieved >= 0)
		--BEGIN
		--	UPDATE [Order]
		--	SET Step = 5 --PAID
		--	WHERE Id = @OrderId
		--END
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@ColorName NVARCHAR(250),
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
	DECLARE @OdId BIGINT

	UPDATE OrderProduct 
	SET
        OrderId =ISNULL(@OrderId,OrderId),
		ProductId =ISNULL(@ProductId,ProductId),
		MaterialId =ISNULL(@MaterialId,MaterialId),
		LocationId =ISNULL(@LocationId,LocationId),
		ColorId =ISNULL(@ColorId,ColorId),
		ColorName=ISNULL(@ColorName,ColorName),
		ControlSideId =ISNULL(@ControlSideId ,ControlSideId),
		UnitId =ISNULL(@UnitId,UnitId),
		[Drop] =ISNULL(@Drop,[Drop]),
		Width =ISNULL(@Width,Width),
		Quantity =ISNULL(@Quantity,Quantity),
		Discount =ISNULL(@Discount,Discount),
		ExtendPrice =ISNULL(@ExtendPrice,ExtendPrice),
		UnitPrice =ISNULL(@UnitPrice,UnitPrice),
		TotalAmount =ISNULL(@TotalAmount,TotalAmount),
		DeliveryNo =ISNULL(@DeliveryNo,DeliveryNo),
		DeliveryDate =ISNULL(@DeliveryDate,DeliveryDate),
		Received =ISNULL(@Received,Received),
		BackOrder =ISNULL(@BackOrder,BackOrder),
		Step=ISNULL(@Step,Step),	
		AMTExcGST=ISNULL(@AMTExcGST,AMTExcGST),
		GST=ISNULL(@GST,GST),
		AMTIncGST=ISNULL(@AMTIncGST,AMTIncGST),
		ReceivedAMTExcGST=ISNULL(@ReceivedAMTExcGST,ReceivedAMTExcGST),
		ReceivedGST=ISNULL(@ReceivedGST,ReceivedGST),
		ReceivedAMTIncGST=ISNULL(@ReceivedAMTIncGST,ReceivedAMTIncGST),
        UpdateDTS= GETDATE()
    WHERE
		Id=@Id

	UPDATE OrderProduct
	SET TotalAmount =ISNULL((UnitPrice + ExtendPrice - ((UnitPrice + ExtendPrice) * Discount/100)) * Quantity,TotalAmount)    
	WHERE
		Id=@Id

	-- Step 2: update amount
	SELECT @OdId = OrderId FROM OrderProduct WITH(NOLOCK)
	WHERE Id = @Id
	EXEC sp_CalculateOrderAmount @OrderId=@OdId
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateProduct]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateProductComponent]    Script Date: 7/17/2018 11:46:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateProductMaterialPrice]    Script Date: 7/17/2018 11:46:44 PM ******/
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
	@GroupId BIGINT,
    @Xml XML,
	@PriceType INT
AS
BEGIN		
	DECLARE @CreateDTS DATETIME = NULL

	IF OBJECT_ID('tempdb..#XMLColumns') IS NOT NULL
	DROP TABLE #XMLColumns

	SELECT x.value('Row[1]', 'INT') AS Row
	,x.value('Column[1]', 'INT') AS [Column]
	,x.value('Value[1]', 'NVARCHAR(50)') AS Value
	INTO #XMLColumns
	FROM @Xml.nodes('/ArrayOfProductPrice/ProductPrice') TempXML (x)
	
	--step 1: get create dts of group active
	SELECT TOP 1 @CreateDTS = CreateDTS
	FROM ProductPrice WITH(NOLOCK)
	WHERE ProductMaterialId=@ProductMaterialId AND IsActive = 1 AND PriceType = @PriceType

	-- step 2: check null @CreateDTS & @GroupId
	IF @CreateDTS IS NULL
	BEGIN
		SELECT @CreateDTS = GETDATE()
			,@GroupId = [dbo].ToTicks(@CreateDTS)
		
	END

	--SELECT @CreateDTS = ISNULL(@CreateDTS,GETDATE())
	--		,@GroupId = CASE WHEN @CreateDTS IS NULL THEN [dbo].ToTicks(@CreateDTS) ELSE @GroupId END

	-- step 3: Delete data of group
    DELETE ProductPrice
	WHERE ProductMaterialId=@ProductMaterialId AND GroupId = @GroupId AND PriceType = @PriceType

	-- step 4: update all group to inactive
	UPDATE ProductPrice
	SET IsActive = 0 
	WHERE ProductMaterialId=@ProductMaterialId AND PriceType = @PriceType

	-- step 5: insert new group, set this group is active
	INSERT INTO ProductPrice(ProductMaterialId,[Row],[Column],[Value],UpdateDTS,CreateDTS,IsActive,GroupId,PriceType)
	SELECT @ProductMaterialId,[Row],[Column],[Value],GETDATE(),@CreateDTS,1,@GroupId,@PriceType
	FROM #XMLColumns
END



GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateSupplier]    Script Date: 7/17/2018 11:46:44 PM ******/
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
    @Fax NVARCHAR(250),
	@ABN NVARCHAR(250)
AS
BEGIN	
	UPDATE Supplier
	SET 
        FirstName=ISNULL(@FirstName,FirstName),
        LastName=ISNULL(@LastName,LastName),
        Company=ISNULL(@Company,Company),
        Email=ISNULL(@Email,Email),
        JobTitle=ISNULL(@JobTitle,JobTitle),
        WebPage=ISNULL(@WebPage,WebPage),
        Notes=ISNULL(@Notes,Notes),
        Address=ISNULL(@Address,Address),
        ZipCode=ISNULL(@ZipCode,ZipCode),
        City=ISNULL(@City,City),
        State=ISNULL(@State,State),
        Country=ISNULL(@Country,Country),
        BusinessPhone=ISNULL(@BusinessPhone,BusinessPhone),
        MobilePhone=ISNULL(@MobilePhone,MobilePhone),
        HomePhone=ISNULL(@HomePhone,HomePhone),
        Fax=ISNULL(@Fax,Fax),
		ABN=ISNULL(@ABN,ABN),
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
USE [master]
GO
ALTER DATABASE [BWC] SET  READ_WRITE 
GO
