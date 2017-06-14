
create procedure __ShardManagement.spGetAllShardMappingsGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int, 
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier,
			@shardVersion uniqueidentifier,
			@minValue varbinary(128),
			@maxValue varbinary(128)

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@shardId = x.value('(Shard[@Null="0"]/Id)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(Shard[@Null="0"]/Version)[1]', 'uniqueidentifier'),
		@minValue = convert(varbinary(128), x.value('(Range[@Null="0"]/MinValue)[1]', 'varchar(258)'), 1),
		@maxValue = convert(varbinary(128), x.value('(Range[@Null="0"]/MaxValue[@Null="0"])[1]', 'varchar(258)'), 1)
	from
		@input.nodes('/GetAllShardMappingsGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	declare @shardMapType int

	select 
		@shardMapType = ShardMapType
	from
		__ShardManagement.ShardMapsGlobal
	where
		ShardMapId = @shardMapId

	if (@shardMapType is null)
		goto Error_ShardMapNotFound;

	declare @currentShardVersion uniqueidentifier

	if (@shardId is not null)
	begin
		if (@shardVersion is null)
			goto Error_MissingParameters;
			
		select 
			@currentShardVersion = Version
		from
			__ShardManagement.ShardsGlobal
		where
			ShardMapId = @shardMapId and ShardId = @shardId and Readable = 1

		if (@currentShardVersion is null)
			goto Error_ShardDoesNotExist;

	end
			
	declare @tvShards table (
		ShardId uniqueidentifier not null, 
		Version uniqueidentifier not null, 
		Protocol int not null,
		ServerName nvarchar(128) collate SQL_Latin1_General_CP1_CI_AS not null, 
		Port int not null,
		DatabaseName nvarchar(128) collate SQL_Latin1_General_CP1_CI_AS not null, 
		Status int not null,
		primary key (ShardId)
	)

	insert into
		@tvShards
	select
		ShardId = s.ShardId,
		Version = s.Version,
		Protocol = s.Protocol,
		ServerName = s.ServerName,
		Port = s.Port,
		DatabaseName = s.DatabaseName,
		Status = s.Status
	from
		__ShardManagement.ShardsGlobal s
	where
		(@shardId is null or s.ShardId = @shardId) and s.ShardMapId = @shardMapId
		

	declare @minValueCalculated varbinary(128) = 0x,
			@maxValueCalculated varbinary(128) = null

	if (@minValue is not null)
		set @minValueCalculated = @minValue

	if (@maxValue is not null)
		set @maxValueCalculated = @maxValue

	if (@shardMapType = 1)
	begin
		select
			3, m.MappingId, m.ShardMapId, m.MinValue, m.MaxValue, m.Status, m.LockOwnerId,  -- fields for SqlMapping
			s.ShardId, s.Version, m.ShardMapId, s.Protocol, s.ServerName, s.Port, s.DatabaseName, s.Status -- fields for SqlShard, ShardMapId is repeated here
		from
			__ShardManagement.ShardMappingsGlobal m
		join 
			@tvShards s 
		on 
			m.ShardId = s.ShardId
		where
			m.ShardMapId = @shardMapId and 
			m.Readable = 1 and
			(@shardId is null or m.ShardId = @shardId) and 
			MinValue >= @minValueCalculated and 
			((@maxValueCalculated is null) or (MinValue < @maxValueCalculated))
		order by 
			m.MinValue
	end
	else
	begin
		select
			3, m.MappingId, m.ShardMapId, m.MinValue, m.MaxValue, m.Status, m.LockOwnerId,  -- fields for SqlMapping
			s.ShardId, s.Version, m.ShardMapId, s.Protocol, s.ServerName, s.Port, s.DatabaseName, s.Status -- fields for SqlShard, ShardMapId is repeated here
		from
			__ShardManagement.ShardMappingsGlobal m
		join 
			@tvShards s 
		on 
			m.ShardId = s.ShardId
		where
			m.ShardMapId = @shardMapId and 
			m.Readable = 1 and
			(@shardId is null or m.ShardId = @shardId) and 
			((MaxValue is null) or (MaxValue > @minValueCalculated)) and 
			((@maxValueCalculated is null) or (MinValue < @maxValueCalculated))
		order by
			m.MinValue
	end

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_ShardDoesNotExist:
	set @result = 202
	goto Exit_Procedure;


Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_GSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Exit_Procedure:
end