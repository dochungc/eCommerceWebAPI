USE eCommerce
GO

/****** Object:  StoredProcedure [dbo].[sp_Suppliers]  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[sp_Suppliers]
@Activity						NVARCHAR(50)		=		NULL,
-----------------------------------------------------------------
@PageIndex						INT					=		0,
@PageSize						INT					=		10,
@SearchString					NVARCHAR(MAX)		=		NULL,
-----------------------------------------------------------------
@Id						        UNIQUEIDENTIFIER	=		NULL,
@Name							NVARCHAR(150)		=		NULL,
@Description					NVARCHAR(255)		=		NULL,
@Address                        NVARCHAR(255)       =       NULL,
@Phone                          VARCHAR(10)         =       NULL,
@Email                          NVARCHAR(100)       =       NULL,
@ContactPerson                  NVARCHAR(255)       =       NULL,
@Status                         BIT                 =       NULL,
@CreatedTime                    DATETIME            =       NULL,
@CreatorId                      UNIQUEIDENTIFIER    =       NULL,
@ModifiedTime                   DATETIME            =       NULL,
@ModifierId                     UNIQUEIDENTIFIER    =       NULL,
@IsDeleted						BIT                 =       0
-----------------------------------------------------------------
AS
IF @Activity = 'INSERT'
BEGIN
	INSERT INTO Supplier(Id, [Name], [Description], [Address], Phone, Email, ContactPerson, [Status], TotalAmountOwed, CreatedTime, CreatorId, IsDeleted) 
	VALUES (@Id, @Name, @Description, @Address, @Phone, @Email, @ContactPerson, 1, 0, GETDATE(), @CreatorId, 0)
END

-----------------------------------------------------------------
ELSE IF @Activity = 'UPDATE'
BEGIN
	UPDATE Supplier
	SET 
		[Name] = ISNULL(@Name, [Name]),
		[Description] = ISNULL(@Description, [Description]),
		[Address] = ISNULL(@Address, [Address]),
		Phone = ISNULL(@Phone, Phone),
		Email = ISNULL(@Email, Email),
		ContactPerson = ISNULL(@ContactPerson, ContactPerson),
		[Status] = ISNULL(@Status, [Status]),
		ModifiedTime = GETDATE(),
		ModifierId = ISNULL(@ModifierId, ModifierId)
	WHERE Id = @Id AND IsDeleted = 0
END

-----------------------------------------------------------------
ELSE IF @Activity = 'CHANGE_STATUS'
BEGIN
	UPDATE Supplier
	SET [Status] = ~[Status] WHERE Id = @Id
END

-----------------------------------------------------------------
ELSE IF @Activity = 'DELETE'
BEGIN
	UPDATE Supplier SET IsDeleted = 1 WHERE Id = @Id
END

-----------------------------------------------------------------
ELSE IF @Activity = 'CHECK_DUPLICATE'
BEGIN
	SELECT TOP 1 1
	FROM Supplier (NOLOCK)
	WHERE ([Name] = @Name OR Phone = @Phone OR Email = @Email) AND (@Id IS NULL OR Id <> @Id) AND IsDeleted = 0
END

-----------------------------------------------------------------
ELSE IF @Activity = 'GET_BY_ID'
BEGIN
	SELECT Id, [Name], [Description], [Address], [Phone], Email, ContactPerson, [Status], TotalAmountOwed
	FROM Supplier AS s (NOLOCK)
	WHERE s.Id = @Id AND s.IsDeleted = 0
END

-----------------------------------------------------------------
ELSE IF @Activity = 'GET_DETAILS_BY_ID'
BEGIN
	SELECT Id, [Name], [Description], [Address], [Phone], Email, ContactPerson, [Status], TotalAmountOwed, CreatedTime, CreatorId, ModifiedTime, ModifierId
	FROM Supplier AS s (NOLOCK)
	WHERE s.Id = @Id AND s.IsDeleted = 0
END

-----------------------------------------------------------------
ELSE IF @Activity = 'GET_ALL'
BEGIN
	;WITH SupplierTemp AS (
		SELECT s.Id
		FROM Supplier (NOLOCK) s
		WHERE (@SearchString IS NULL 
		OR @SearchString = '' 
		OR s.[Name] LIKE N'%'+@SearchString+'%' 
		OR  s.[Description] LIKE N'%'+@SearchString+'%'
		OR  s.[Phone] LIKE N'%'+@SearchString+'%'
		OR  s.Email LIKE N'%'+@SearchString+'%' 
		OR  s.ContactPerson LIKE N'%'+@SearchString+'%') 
		AND s.IsDeleted = 0
	)
	SELECT s.Id, s.[Name], s.[Description], s.[Address], s.Phone, s.Email, s.ContactPerson, s.[Status], s.TotalAmountOwed, RecordCount.TotalRows as TotalRows
	FROM SupplierTemp AS st
		CROSS JOIN 
		(
			SELECT COUNT(*) AS TotalRows
			FROM SupplierTemp
		) as RecordCount
		INNER JOIN Supplier (NOLOCK) s ON s.Id = st.Id
	ORDER BY s.CreatedTime DESC
	OFFSET ((@PageIndex - 1) * @PageSize) ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
GO

UPDATE Supplier SET TotalAmountOwed = 0 WHERE 1 = 1
GO
