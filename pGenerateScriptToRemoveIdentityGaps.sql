/*

A few notes about this script...

1) Currently it won't work on any database earlier than 4.7 because APXSys.pPrint doesn't exist. If that is the case,
   just uncomment the block at the top and it will create a version of APXSys.pPrint that appears to work in most cases.

2) If run against a table that has FKs into it, it will reset the FK values - but that part doesn't use chunking, and it really should.
   However, I don't know when we would actually need to resequence identity columns on such a table.

*/

--if object_id('APXSys.pPrint') is null
--begin

--	declare @x nvarchar(max)
--	set @x = '
--	create procedure APXSys.pPrint
--		@textVal nvarchar(max)
--	as 
--	begin

--		declare @eol nvarchar(max) = char(13)+char(10)
--		declare @iStart int
		
--		while len(@textVal) > 0
--		begin

--			set @iStart = charindex(@eol, @textVal, 0)
			
--			if @iStart > 0
--			begin
--				print substring(@textVal, 0, @iStart)
--				set @textVal = substring(@textVal, @iStart+len(@eol), len(@textVal)-@iStart)
--			end
--			else
--			begin
--				print @textVal
--				set @textVal = ''''
--			end
			
--		end

--	end'

--	exec(@x)	
--end
--go

IF OBJECT_ID('APXSys.fOnOrOffText') IS NOT NULL
    DROP FUNCTION APXSys.fOnOrOffText
GO

-- $Header: $/APX/Trunk/APX/APXDatabase/UtilScripts/sp/pGenerateScriptToRemoveIdentityGaps.sql  2014-08-15 15:06:46 PDT  ADVENT/tbratsos $

CREATE FUNCTION APXSys.fOnOrOffText(@on bit)
RETURNS nvarchar(max)
AS
BEGIN
    RETURN case when @on = 1 then 'ON' else 'OFF' end
END
GO

if object_id('APXSys.fGenerateCreateForeignKeyScript') is not null
	drop function APXSys.fGenerateCreateForeignKeyScript
go

-- $Header: $/APX/Trunk/APX/APXDatabase/UtilScripts/sp/pGenerateScriptToRemoveIdentityGaps.sql  2014-08-15 15:06:46 PDT  ADVENT/tbratsos $

-- Generate a script to create a foreign key.
-- Optionally map the column in the leaf table that corresponds to the identity column of the original table.

create function APXSys.fGenerateCreateForeignKeyScript
(
	@object_id int,
	@tableobjectid int,
	@mapalias sysname = null
)
returns nvarchar(max)
as
begin
	declare
	 	@script nvarchar(max) = '',
		@txt nvarchar(max), 
		@par_collist nvarchar(max),
		@ref_collist nvarchar(max),
		@eol nvarchar(max),
		@tab nvarchar(max) = CHAR(9),
		@goline nvarchar(max)

	set @eol = char(13)+char(10)
	set @goline = 'GO' + @eol + @eol

	set @par_collist = ''
	set @ref_collist = ''
	declare @leaf_fk_refs_id_col int
	set @leaf_fk_refs_id_col = 0
	
	select
		@par_collist = @par_collist + '[' + p.name + '],',
		@ref_collist = @ref_collist + '[' + r.name + '],',
		@leaf_fk_refs_id_col = @leaf_fk_refs_id_col + case when s.referenced_object_id = @tableobjectid and r.is_identity = 1 then 1 else 0 end
	from sys.foreign_key_columns s 
	join sys.columns p on p.object_id = s.parent_object_id and p.column_id = s.parent_column_id
	join sys.columns r on r.object_id = s.referenced_object_id and r.column_id = s.referenced_column_id
	where s.constraint_object_id = @object_id
	order by s.constraint_column_id

	if @mapalias is not null and @leaf_fk_refs_id_col <> 0
	begin
		-- Map the column in the leaf table that corresponds to the identity column of the original table.
		select @txt = 
			'-- Map the column in the leaf table that corresponds to the identity column of the original table.' + @eol +
			'IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N''[' + m.name + '].[' + t.name + '_TU_Audit]''))' + @eol + 
			@tab + 'DISABLE TRIGGER ' + m.name + '.' + t.name + '_TU_Audit ON ' + m.name + '.' + t.name + @eol + @goline +
			'update ' + m.name + '.' + t.name + ' set ' + p.name + ' = NewID from ' + @mapalias + ' where OldID = ' + p.name + @eol + @goline +
			'IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N''[' + m.name + '].[' + t.name + '_TU_Audit]''))' + @eol + 
			@tab + 'ENABLE TRIGGER ' + m.name + '.' + t.name + '_TU_Audit ON ' + m.name + '.' + t.name + @eol + @goline
		from sys.foreign_key_columns s 
		join sys.columns p on p.object_id = s.parent_object_id and p.column_id = s.parent_column_id
		join sys.objects t on t.object_id = s.parent_object_id
		join sys.schemas m on m.schema_id = t.schema_id
		join sys.columns r on r.object_id = s.referenced_object_id and r.column_id = s.referenced_column_id
		where s.constraint_object_id = @object_id
		and s.referenced_object_id = @tableobjectid and r.is_identity = 1

		set @script =  @script + @eol + @txt
	end

	set @par_collist = '(' + left(@par_collist, len(@par_collist)-1) + ')'
	set @ref_collist = '(' + left(@ref_collist, len(@ref_collist)-1) + ')'

	select @txt = 
		'ALTER TABLE [' + m.name + '].[' + p.name + '] WITH CHECK ADD CONSTRAINT [' + s.name + '] FOREIGN KEY' + @par_collist + @eol +
		'REFERENCES [' + t.name + '].[' + r.name + '] ' + @ref_collist + @eol +
		'ON UPDATE ' + case when s.update_referential_action = 1 then 'CASCADE' else 'NO ACTION' end + @eol +
		'ON DELETE ' + case when s.delete_referential_action = 1 then 'CASCADE' else 'NO ACTION' end + @eol + @goline +
		'ALTER TABLE [' + m.name + '].[' + p.name + '] CHECK CONSTRAINT [' + s.name + ']' + @eol + @goline
	from sys.foreign_keys s 
	join sys.objects p on p.object_id = s.parent_object_id
	join sys.objects r on r.object_id = s.referenced_object_id
	join sys.schemas m on m.schema_id = p.schema_id
	join sys.schemas t on t.schema_id = r.schema_id
	where s.object_id = @object_id

	set @script =  @script + @eol + @txt

	return @script

end
go

if object_id('APXSys.fGenerateCreateIndexScript') is not null
	drop function APXSys.fGenerateCreateIndexScript
go

-- $Header: $/APX/Trunk/APX/APXDatabase/UtilScripts/sp/pGenerateScriptToRemoveIdentityGaps.sql  2014-08-15 15:06:46 PDT  ADVENT/tbratsos $

-- Generate a script to create an index on a table or a view.
create function APXSys.fGenerateCreateIndexScript
(
	@object_id int,
	@index_id int
)
returns nvarchar(max)
as
begin
	declare
	 	@script nvarchar(max) = '',
		@txt nvarchar(max), 
		@part1 nvarchar(max),
		@part2 nvarchar(max),
		@eol nvarchar(max),
		@tab nvarchar(max) = CHAR(9),
		@goline nvarchar(max)

	set @eol = char(13)+char(10)
	set @goline = 'GO' + @eol + @eol

	select 
		@part1 = 
			case when s.is_primary_key = 0 then
	   			'CREATE ' + case when s.is_unique = 1 then 'UNIQUE' else '' end + ' ' + case when s.type = 1 then 'CLUSTERED' else 'NONCLUSTERED' end + ' INDEX ' + s.name +
				' ON ' + m.name + '.' + o.name
			else
				'ALTER TABLE [' + m.name + '].[' + o.name + '] ADD  CONSTRAINT [' + s.name + '] PRIMARY KEY ' + case when s.type = 1 then 'CLUSTERED' else 'NONCLUSTERED' end 
			end,

		@part2 =
			'WITH (PAD_INDEX = ' + APXSys.fOnOrOffText(s.is_padded) + 
			', STATISTICS_NORECOMPUTE = ' + APXSys.fOnOrOffText(w.no_recompute) + 
			', SORT_IN_TEMPDB = OFF' + -- OFF so we do not run out of tempdb space
			', IGNORE_DUP_KEY = ' + APXSys.fOnOrOffText(s.ignore_dup_key) + 
			case when s.is_primary_key = 0 then ', DROP_EXISTING = OFF' else '' end + -- OFF because the index doesn't exist now
			', ONLINE = OFF' + @eol + @tab + -- OFF because not supported in older versions
			', ALLOW_ROW_LOCKS  = ' + APXSys.fOnOrOffText(s.allow_row_locks) + 
			', ALLOW_PAGE_LOCKS  = ' + APXSys.fOnOrOffText(s.allow_page_locks) +
			case when IsNull(s.fill_factor, 0) <> 0 then ', FILLFACTOR = ' + cast (s.fill_factor as nvarchar(max)) else '' end + 
			') ON [' + d.name + ']'

	from sys.indexes s 
	join sys.objects o on o.object_id = s.object_id
	join sys.schemas m on m.schema_id = o.schema_id
	join sys.data_spaces d on d.data_space_id = s.data_space_id
	join sys.stats w on w.name = s.name and w.stats_id = s.index_id
	where s.index_id = @index_id and s.object_id = @object_id

	set @script =  @script + @eol + @part1 + @eol + '('

	set @txt = ''

	select @txt = @txt + @eol + @tab + '[' + c.name + ']' + case when i.is_descending_key = 0 then ' ASC' else ' DESC' end + ','
	from sys.index_columns i
	join sys.columns c on c.column_id = i.column_id and c.object_id = @object_id
	where i.object_id = @object_id and i.index_id = @index_id
	order by i.index_column_id

	set @script =  @script + left(@txt, len(@txt)-1) + @eol + ')' + @eol + @part2 + @eol + @goline + @eol

	return @script

end
go

if object_id('APXSys.pRenameCloneToOriginal') is not null
	drop procedure APXSys.pRenameCloneToOriginal
go

-- $Header: $/APX/Trunk/APX/APXDatabase/UtilScripts/sp/pGenerateScriptToRemoveIdentityGaps.sql  2014-08-15 15:06:46 PDT  ADVENT/tbratsos $

create procedure APXSys.pRenameCloneToOriginal
(
	@clone sysname,
	@mapalias sysname,
	@tableobjectid int,
	@partscript nvarchar(max) output
)
as
begin try
	declare 
		@txt nvarchar(max), 
		@part1 nvarchar(max),
		@part2 nvarchar(max),
		@par_collist nvarchar(max),
		@ref_collist nvarchar(max),
		@eol nvarchar(max),
		@white nvarchar(max),
		@tab nvarchar(max) = CHAR(9),
		@original_brackets nvarchar(max),
		@original_no_schema sysname,
		@original sysname,
		@goline nvarchar(max)

	set @eol = char(13)+char(10)
	set @goline = 'GO' + @eol + @eol
	set @white = ' ' + @eol + @tab

	select @original_brackets = '[' + m.name + '].[' + o.name + ']', @original_no_schema = o.name, @original = m.name + '.' + o.name
	from sys.objects o
	join sys.schemas m on m.schema_id = o.schema_id
	where o.object_id = @tableobjectid

	set @partscript =  '-- Rename ' + @clone + ' to ' + @original + @eol

	if exists 
	(
		select *
		from sys.foreign_keys s
		where s.parent_object_id = @tableobjectid or s.referenced_object_id = @tableobjectid 
	)
	begin
		set @partscript =  @partscript + @eol + '-- Drop FOREIGN KEY CONSTRAINTs' + @eol
	
		set @txt = ''

		select @txt = @txt + @eol +
			'IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''[' + m.name + '].[' + s.name + ']'') ' + 
			'AND parent_object_id = OBJECT_ID(N''' + q.name + '.' + p.name + '''))' + @eol +
			'ALTER TABLE [' + q.name + '].[' + p.name + '] DROP CONSTRAINT [' + s.name + ']' + @eol + @goline
		from sys.foreign_keys s
		join sys.schemas m on m.schema_id = s.schema_id
		join sys.objects p on p.object_id = s.parent_object_id
		join sys.schemas q on q.schema_id = p.schema_id
		--where s.parent_object_id = @tableobjectid or s.referenced_object_id = @tableobjectid 
		where s.referenced_object_id = @tableobjectid 

		set @partscript =  @partscript + @eol + @txt
	end

	--if exists 
	--(
	--	select *
	--	from sys.check_constraints s
	--	where s.parent_object_id = @tableobjectid
	--)
	--begin
	--	set @partscript =  @partscript + @eol + '-- Drop CHECK CONSTRAINTs' + @eol
	
	--	set @txt = ''

	--	select @txt = @txt + @eol +
	--		'IF EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N''[' + m.name + '].[' + s.name + ']'') AND parent_object_id = OBJECT_ID(N''' + @original + '''))' + @eol +
	--		'ALTER TABLE ' + @original_brackets + ' DROP CONSTRAINT [' + s.name + ']' + @eol + @goline
	--	from sys.check_constraints s
	--	join sys.schemas m on m.schema_id = s.schema_id
	--	where s.parent_object_id = @tableobjectid

	--	set @partscript =  @partscript + @eol + @txt
	--end

	--if exists 
	--(
	--	select *
	--	from sys.default_constraints s
	--	where s.parent_object_id = @tableobjectid
	--)
	--begin
	--	set @partscript =  @partscript + @eol + '-- Drop DEFAULT CONSTRAINTs' + @eol
	
	--	set @txt = ''

	--	select @txt = @txt + @eol +
	--		'IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N''[' + s.name + ']'') AND type = ''D'')' + @eol + 
	--		'ALTER TABLE ' + @original_brackets + ' DROP CONSTRAINT [' + s.name + ']' + @eol + @goline
	--	from sys.default_constraints s
	--	where s.parent_object_id = @tableobjectid

	--	set @partscript =  @partscript + @eol + @txt
	--end

	--if exists 
	--(
	--	select *
	--	from sys.triggers s
	--	where s.parent_id = @tableobjectid
	--)
	--begin
	--	set @partscript =  @partscript + @eol + '-- Drop TRIGGERs' + @eol
	
	--	set @txt = ''

	--	select @txt = @txt + @eol +
	--		'IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N''[' + m.name + '].[' + s.name + ']''))' + @eol + 
	--		'DROP TRIGGER ' + '[' + m.name + '].[' + s.name + ']' + @eol + @goline
	--	from sys.triggers s
	--	join sys.objects o on o.object_id = s.object_id
	--	join sys.schemas m on m.schema_id = o.schema_id
	--	where s.parent_id = @tableobjectid

	--	set @partscript =  @partscript + @eol + @txt
	--end

	--if exists 
	--(
	--	select *
	--	from sys.indexes s
	--	where s.object_id = @tableobjectid
	--)
	--begin
	--	set @partscript =  @partscript + @eol + '-- Drop INDEXes (clustered last)' + @eol
	
	--	set @txt = ''

	--	select @txt = @txt + @eol +
	--		'IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[' + m.name + '].[' + o.name + ']'') AND name = N''' + s.name + ''')' + @eol +
	--		case when s.is_primary_key = 1 then 
	--			'ALTER TABLE ' + @original_brackets + ' DROP CONSTRAINT [' + s.name + ']'
	--		else
	--			'DROP INDEX [' + s.name + '] ON [' + m.name + '].[' + o.name + '] WITH ( ONLINE = OFF )' 
	--		end
	--		+ @eol + @goline

	--	from sys.indexes s
	--	join sys.objects o on o.object_id = s.object_id
	--	join sys.schemas m on m.schema_id = o.schema_id
	--	where s.object_id = @tableobjectid
	--	order by case when s.type = 1 then 1 else 0 end -- clustered last

	--	set @partscript =  @partscript + @eol + @txt
	--end

	if exists 
	(
		select d.object_id
		from sys.sql_dependencies d 
		join sys.sql_modules m on m.object_id = d.object_id
		join sys.objects c on c.object_id = d.object_id
		where d.referenced_major_id = @tableobjectid and m.is_schema_bound = 1 and c.type = 'V'
	)
	begin
		set @txt = '-- Drop schema bound views that depend on the original table.' + @eol + @goline
		select @txt = @txt + @eol +
			'IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[' + e.name + '].[' + o.name + ']''))' + @eol +
			'DROP VIEW [' + e.name + '].[' + o.name + ']' + @eol + @goline
		from sys.sql_modules m
		join sys.objects o on o.object_id = m.object_id
		join sys.schemas e on e.schema_id = o.schema_id
		where m.object_id in
		(
			select distinct d.object_id
			from sys.sql_dependencies d 
			join sys.sql_modules m on m.object_id = d.object_id
			join sys.objects c on c.object_id = d.object_id
			where d.referenced_major_id = @tableobjectid and m.is_schema_bound = 1 and c.type = 'V'
		) 

		set @partscript =  @partscript + @eol + @txt

	end

	set @partscript =  @partscript + @eol + 
		'-- Drop original table.' + @eol +
		'IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @original_brackets + ''') AND type in (N''U''))' + @eol +
		'DROP TABLE ' + @original + @eol + @goline

	set @partscript =  @partscript + @eol + '-- Rename clone to original.' + @eol + 
		'exec sp_rename @objname = ''' + @clone + ''', @newname =''' + @original_no_schema + ''', @objtype = ''OBJECT''' + @eol + @goline

	if exists 
	(
		select d.object_id
		from sys.sql_dependencies d 
		join sys.sql_modules m on m.object_id = d.object_id
		join sys.objects c on c.object_id = d.object_id
		where d.referenced_major_id = @tableobjectid and m.is_schema_bound = 1 and c.type = 'V'
	)
	begin
		set @txt = '-- Restore schema bound views that depend on the original table.' + @eol + @goline
		select @txt = @txt + @eol + m.definition + @eol + @goline +
			case when i.index_id is not null then APXSys.fGenerateCreateIndexScript(i.object_id, i.index_id) else '' end
		from sys.sql_modules m
		left join sys.indexes i on i.object_id = m.object_id
		where m.object_id in
		(
			select distinct d.object_id
			from sys.sql_dependencies d 
			join sys.sql_modules m on m.object_id = d.object_id
			join sys.objects c on c.object_id = d.object_id
			where d.referenced_major_id = @tableobjectid and m.is_schema_bound = 1 and c.type = 'V'
		) 

		set @partscript =  @partscript + @eol + @txt

	end

	if exists 
	(
		select *
		from sys.indexes s
		where s.object_id = @tableobjectid
	)
	begin
		set @txt =  '-- Replace INDEXes (clustered first)'

		select 
			@txt = @txt + @eol + APXSys.fGenerateCreateIndexScript(s.object_id, s.index_id)
 		from sys.indexes s
 		where s.object_id = @tableobjectid
		 
		set @partscript =  @partscript + @eol + @txt
	end

	if exists 
	(
		select *
		from sys.triggers s
		where s.parent_id = @tableobjectid
	)
	begin
		set @partscript =  @partscript + @eol + '-- Replace TRIGGERs' + @eol
	
		set @txt = ''

		select @txt = @txt + @eol + 
			'SET ANSI_NULLS ' + APXSys.fOnOrOffText(m.uses_ansi_nulls) + @eol + @goline + 
			'SET QUOTED_IDENTIFIER ' + APXSys.fOnOrOffText(m.uses_quoted_identifier) + @eol + @goline + 
			m.definition + @eol + @goline
		from sys.triggers s
		join sys.sql_modules m on m.object_id = s.object_id
		where s.parent_id = @tableobjectid

		select @txt = @txt + @eol + 
	   		'EXEC sp_settriggerorder @triggername=N''[' + h.name + '].[' + s.name + ']'', @order=N''' + 
			case when e.is_first = 1 then 'First' else 'Last' end + ''', @stmttype=N''' + e.type_desc + '''' + @eol + @goline 
		from sys.triggers s
		join sys.trigger_events e on e.object_id = s.object_id
		join sys.objects o on o.object_id = s.object_id
		join sys.schemas h on h.schema_id = o.schema_id
		where s.parent_id = @tableobjectid
		and e.is_first = 1 or e.is_last = 1

		set @partscript =  @partscript + @eol + @txt
	end

	if exists 
	(
		select *
		from sys.foreign_keys s
		where s.parent_object_id = @tableobjectid or s.referenced_object_id = @tableobjectid 
	)
	begin
		set @txt =  '-- Replace FOREIGN KEY CONSTRAINTs' + @eol
		select @txt = @txt + APXSys.fGenerateCreateForeignKeyScript(s.object_id, @tableobjectid, @mapalias) + @eol
		from sys.foreign_keys s
		where s.parent_object_id = @tableobjectid or s.referenced_object_id = @tableobjectid 

	 	set @partscript =  @partscript + @eol + @txt
	end

	if exists 
	(
		select *
		from sys.check_constraints s
		where s.parent_object_id = @tableobjectid
	)
	begin
		set @partscript =  @partscript + @eol + '-- Replace CHECK CONSTRAINTs' + @eol
	
		set @txt = ''

		select @txt = @txt + @eol +
			'ALTER TABLE [' + m.name +'].[' + o.name + '] WITH CHECK ADD CONSTRAINT [' + s.name + '] CHECK (' + s.definition + ')' + @eol + @goline + @eol +
			'ALTER TABLE [' + m.name +'].[' + o.name + '] CHECK CONSTRAINT [' + s.name + ']' + @eol + @goline
		from sys.check_constraints s
		join sys.objects o on o.object_id = s.parent_object_id
		join sys.schemas m on m.schema_id = o.schema_id
		where s.parent_object_id = @tableobjectid

		set @partscript =  @partscript + @eol + @txt
	end

	if exists 
	(
		select *
		from sys.default_constraints s
		where s.parent_object_id = @tableobjectid
	)
	begin
		set @partscript =  @partscript + @eol + '-- Replace DEFAULT CONSTRAINTs' + @eol
	
		set @txt = ''

		select 
			@txt = @txt + @eol + 'ALTER TABLE ' + @original_brackets + ' ADD CONSTRAINT [' + s.name + '] DEFAULT ' + s.definition + ' FOR [' + c.name + ']' + @eol + @goline + @eol
		from sys.default_constraints s
		join sys.columns c on c.object_id = s.parent_object_id and c.column_id = s.parent_column_id
		where s.parent_object_id = @tableobjectid

		set @partscript =  @partscript + @eol + @txt
	end

end try
begin catch
	execute APX.pRethrowError;
end catch
go


if object_id('APXSys.pGenerateScriptToRemoveIdentityGaps') is not null
	drop procedure APXSys.pGenerateScriptToRemoveIdentityGaps
go

-- $Header: $/APX/Trunk/APX/APXDatabase/UtilScripts/sp/pGenerateScriptToRemoveIdentityGaps.sql  2014-08-15 15:06:46 PDT  ADVENT/tbratsos $

create procedure APXSys.pGenerateScriptToRemoveIdentityGaps
(
	@dbname sysname,
	@schema sysname,
	@table sysname
)
as
begin try
	declare 
		@suffix sysname = 'Clone',
		@identitycol sysname,
		@fullscript nvarchar(max), 
		@partscript nvarchar(max), 
		@txt nvarchar(max), 
		@eol nvarchar(max),
		@eol_indented nvarchar(max),
		@eol_normal nvarchar(max),
		@tab nvarchar(max) = CHAR(9),
		@goline nvarchar(max),
		@audit sysname = '_Audit'

	set @eol = char(13)+char(10)
	set @eol_normal = @eol
	set @eol_indented = @eol_normal + @tab
	set @goline = 'GO' + @eol + @eol

	declare @schemaid int
	select @schemaid = schema_id from sys.schemas where name = @schema
	if @schemaid is null raiserror('No such schema (%s)', 16, 1, @schema)
	declare @tableobjectid int
	select @tableobjectid = object_id from sys.tables where name = @table and schema_id = @schemaid
	if @tableobjectid is null raiserror('No such table (%s) in schema (%s)', 16, 1, @table, @schema)
	select @identitycol = name from sys.all_columns where object_id = @tableobjectid and is_identity = 1
	if @identitycol is null raiserror('The table (%s.%s) does not have an IDENTITY column', 16, 1, @schema, @table)

	declare @maptable sysname
	set @maptable = 'Temp.' + @identitycol + 'Map'
	
	declare @mapalias sysname
	set @mapalias = 'Temp.IDMap'

	declare @mapindex sysname
	set @mapindex = @identitycol + 'Map_Index'

	declare @fulltable sysname
	set @fulltable = @schema + '.' + @table

	declare @clonetable sysname
	set @clonetable = @table + @suffix

	declare @fullclone sysname
	set @fullclone = @schema + '.' + @clonetable

	declare @audittable sysname
	set @audittable = @table + @audit

	declare @fullaudit sysname
	set @fullaudit = @fulltable + @audit 

	declare @auditclone sysname
	set @auditclone = @clonetable + @audit   

	declare @fullauditclone nvarchar(MAX)
	set @fullauditclone = @schema + '.' + @auditclone

	declare @auditobjectid int
	select @auditobjectid = object_id from sys.tables where name = @table + @audit and schema_id = @schemaid

	set @fullscript = 'set nocount on' + @eol + @goline + 'use ' + @dbname + @eol + @goline;

	-- Tim Bratsos thinks this would run faster if we created it in the clustered key order.
	-- He also suggested that we insert into it in chunks.

	set @fullscript =  @fullscript + 
		'-- Create a table to map the old ' + @identitycol + ' to the new ' + @identitycol + ';' + @eol +
		'-- the logic here will place the map table in either the firm_temp (if it exists) or the firm database' + @eol + 
		'-- at run time.' + @eol + @eol +

		'declare @mapdb sysname = db_name()' + @eol + @eol +

		'if exists (select * from sys.databases where name = db_name() + ''_Temp'')' + @eol + 
		'begin' + @eol +
		'	set @mapdb = @mapdb + ''_Temp''' + @eol + 
		'   select ''Map table created in firm_Temp database''' + @eol +
		'end' + @eol +
		'else' + @eol +
		'   select ''firm_Temp database not found, Map table created in firm database''' + @eol +

		@eol +
		
		'exec (''if object_ID(''''' + @mapalias + ''''') is not null drop synonym ' + @mapalias + ''')' + @eol +
		'exec (''if object_ID('''''' + @mapdb + ''.' + @maptable + ''''') is not null drop table '' + @mapdb + ''.' + @maptable + ''')' + @eol + @eol +

		'exec (''create table '' + @mapdb + ''.' + @maptable + ' (OldID int not null, NewID int identity primary key (OldID))'')' + @eol + @eol +

		'exec (''create synonym ' + @mapalias + ' for '' + @mapdb + ''.' + @maptable + ''')' + @eol + @eol + @goline

		--'if object_ID(''' + @maptable + ''') is not null drop table ' + @maptable + @eol +
		--@goline +

		--'create table ' + @maptable + ' (OldID int not null, NewID int identity primary key (OldID))' + @eol +
		--@goline +

		----'create nonclustered index ' + @mapindex + ' ON ' + @maptable + ' ([NewID]) include ([OldID])' + @eol +
		----@goline +

		set @fullscript =  @fullscript + 
			'declare @StartTime datetime = GetDate()' + @eol +
			'select RunOption = ''Clone tables'', StartTime = @StartTime' + @eol +
			'alter database ' + @dbname + ' set recovery simple;' + @eol +
			'--#DEBUG select datediff(Second, @StartTime, GetDate()) as ''Set database recovery mode as simple (Seconds)''' + @eol +
			@goline

		set @fullscript =  @fullscript + 
		'declare @StartTime datetime = GetDate()' + @eol +

		--'insert into ' + @mapalias + '(OldID)' + @eol +
		--'select distinct OldID = ' + @identitycol + @eol +
		--'from (' + @eol +
		--'	select ' + @identitycol + @eol +
		--'	from ' + @fulltable + @eol +
		--'	union ' + @eol +
		--'	select ' + @identitycol + @eol +
		--'	from ' + @fullaudit + @eol +
		--') dat' + @eol +
		--'order by ' + @identitycol + @eol +

		'declare @RowsPerChunk int = 500000' + @eol +
		'declare @MinID int = 0' + @eol +
		'declare @MaxID int' + @eol + @eol +

		'select @MaxID = max(' + @identitycol + ')' + @eol +
		'from' + @eol +
		'(' + @eol +
		'		select ' + @identitycol + '=max(' + @identitycol + ')' + @eol +
		'		from ' + @fullTable + @eol + @eol +

		'		union' + @eol + @eol +

		'		select ' + @identitycol + '=max(' + @identitycol + ')' + @eol +
		'		from ' + @fullaudit + @eol +
		') x' + @eol + @eol +

		'while (@MinID < @MaxID)' + @eol +
		'begin' + @eol + @eol +

		'	insert into ' + @mapalias + ' (OldID)' + @eol +
		'		select ' + @identitycol + @eol +
		'		from (' + @eol +
		'			select ' + @identitycol + @eol +
		'			from ' + @fullTable + @eol +
		'			where ' + @identitycol + ' between @MinID and @MinID + @RowsPerChunk' + @eol + @eol +
		
		'			union' + @eol + @eol + 
		
		'			select ' + @identitycol + @eol +
		'			from ' + @fullaudit + @eol +
		'			where ' + @identitycol + ' between @MinID and @MinID + @RowsPerChunk' + @eol +
		'			group by ' + @identitycol + @eol +
		'		) x' + @eol +
		'		order by ' + @identitycol + @eol + @eol +
	
		'	set @MinID = @MinID + @RowsPerChunk + 1' + @eol + @eol +
	
		'end' + @eol + @eol +

		'select datediff(Second, @StartTime, GetDate()) as ''Fill ' + @identitycol + 'Map (Seconds)''' + @eol +
		@goline +
		'--#DEBUG select count(*) as ' + @identitycol + 'MapCount from ' + @mapalias + @eol +
		'--#DEBUG select top 10 ''' + @mapalias + ''' as AllRows, * from ' + @mapalias + @eol +
		'--#DEBUG select top 10 ''' + @mapalias + ''' as ChgRows, * from ' + @mapalias + ' where OldID <> NewID' + @eol +
		@goline

	set @fullscript =  @fullscript + 
		'if object_ID(''' + @fullclone + ''') is not null drop table ' + @fullclone + @eol + @goline

	set @txt = ''

	select @txt = @txt + @eol + 
		@tab + c.name + ' ' + t.name + 
			case when c.precision = 0 and t.name <> 'timestamp' and c.system_type_id = c.user_type_id then '(' + cast (c.max_length AS nvarchar(64)) + ') ' else ' ' end + 
			case when c.is_identity = 1 then 'IDENTITY ' else '' end + 
			case when c.is_sparse = 1 then 'sparse ' else '' end + 
			case when c.is_nullable = 1 then 'NULL' else 'NOT NULL' end + ','
	from sys.all_columns c
	join sys.types t on c.user_type_id = t.user_type_id
	where c.object_id = @tableobjectid
	order by c.column_id

	set @fullscript =  @fullscript + 
		'create table ' + @fullclone + @eol + '(' + left(@txt, len(@txt)-1) + @eol + ') on PRODDATA' + @eol + @goline

	set @fullscript =  @fullscript + 'set identity_insert ' + @fullclone + ' on' + @eol + @goline

		set @fullscript =  @fullscript + @eol + 'declare @MinOldID int = 0' + @eol +
			'declare @MaxOldID int' + @eol +
			'declare @RowsPerChunk int = 250000' + @eol

	set @fullscript =  @fullscript + @eol + 'declare @StartTime datetime = GetDate()' + @eol

	set @fullscript =  @fullscript + @eol + 'while (1 = 1)' + @eol + 'begin'  + @eol

	set @eol = @eol_indented
	
	set @fullscript = @fullscript + @eol + 'select @MaxOldID=max(OldID)' + @eol
	set @fullscript = @fullscript + 'from' + @eol
	set @fullscript = @fullscript + '(' + @eol
	set @fullscript = @fullscript + '    select top (@RowsPerChunk) OldID' + @eol
	set @fullscript = @fullscript + '    from Temp.IDMap' + @eol
	set @fullscript = @fullscript + '    where OldID >= @MinOldID' + @eol
	set @fullscript = @fullscript + '    order by OldID asc' + @eol
	set @fullscript = @fullscript + ') x' + @eol + @eol
		
	set @fullscript = @fullscript + 'if @MaxOldID is null' + @eol
	set @fullscript = @fullscript + '	break' + @eol + @eol
			
	set @fullscript = @fullscript + '--#DEBUG select MinOldID=@MinOldID, MaxOldID=@MaxOldID' + @eol
	
	set @txt = '' 

	select @txt = @txt + @eol + @tab + c.name + ','
	from sys.all_columns c
	join sys.types t on c.user_type_id = t.user_type_id
	where c.object_id = @tableobjectid
	and t.name <> 'timestamp'
	order by c.column_id

	set @fullscript =  @fullscript + @eol + 'insert into ' + @fullclone + @eol + '(' + left(@txt, len(@txt)-1) + @eol + ')' + @eol + 'select'

	set @txt = '' 

	select @txt = @txt + @eol + 
		@tab + case when c.name = @identitycol then 'map.NewID' else 'tab.' + c.name end + ','
	from sys.all_columns c
	join sys.types t on c.user_type_id = t.user_type_id
	where c.object_id = @tableobjectid
	and t.name <> 'timestamp'
	order by c.column_id

	set @fullscript =  @fullscript + left(@txt, len(@txt)-1) + @eol + 'from ' + @mapalias + ' map' + @eol +
		'join ' + @fulltable + ' tab with (forceseek) on map.OldID = tab.' + @identitycol + @eol +
		'where map.OldID between @MinOldID and @MaxOldID' + @eol

	set @fullscript =  @fullscript + @eol + 'set @MinOldID = @MaxOldID + 1' + @eol
	
	set @eol = @eol_normal

   	set @fullscript =  @fullscript + @eol + 'end' + @eol

   	set @fullscript =  @fullscript + @eol + 'select datediff(Second, @StartTime, GetDate()) as ''Fill ' + @clonetable + ' (Seconds)''' + @eol + @goline

   	set @fullscript =  @fullscript + 'set identity_insert ' + @fullclone + ' off' + @eol + @goline

   	set @fullscript =  @fullscript +
		'--#DEBUG select count(*) as ' + @table + 'Count from ' + @fulltable + @eol +
		'--#DEBUG select count(*) as ' + @table + @suffix + 'Count, min(' + @identitycol + ') as Min' + @identitycol + ' from ' + @fullclone + @eol +
		'--#DEBUG select top 10 * from ' + @fullclone + @eol + @goline

	if @auditobjectid is not null
	begin

	   	set @fullscript =  @fullscript + 
			'-- Create a clone of the audit table via select into and populate it via insert.' + @eol +
			'if object_id(''' + @fullauditclone + ''') is not null drop table ' + @fullauditclone + @eol + @goline

		set @txt = '' 

		select @txt = @txt + @eol + @tab + 'tab.' + c.name + ','
		from sys.all_columns c
		join sys.types t on c.user_type_id = t.user_type_id
		where c.object_id = @auditobjectid
		order by c.column_id

	   	set @fullscript =  @fullscript + 'select' + left(@txt, len(@txt)-1) + @eol +
			'into ' + @fullauditclone + @eol +
			'from ' + @fullaudit + ' tab' + @eol +
			'where 1 = 0' + @eol 

		set @fullscript =  @fullscript + @eol + 'declare @MinOldID int = 0' + @eol +
			'declare @MaxOldID int' + @eol +
			'declare @RowsPerChunk int = 250000' + @eol

		set @fullscript =  @fullscript + @eol + 'declare @StartTime datetime = GetDate()' + @eol

		set @fullscript =  @fullscript + @eol + 'while (1 = 1)' + @eol + 'begin'  + @eol

		set @eol = @eol_indented
		
		set @fullscript = @fullscript + @eol + 'select @MaxOldID=max(OldID)' + @eol
		set @fullscript = @fullscript + 'from' + @eol
		set @fullscript = @fullscript + '(' + @eol
		set @fullscript = @fullscript + '    select top (@RowsPerChunk) OldID' + @eol
		set @fullscript = @fullscript + '    from Temp.IDMap' + @eol
		set @fullscript = @fullscript + '    where OldID >= @MinOldID' + @eol
		set @fullscript = @fullscript + '    order by OldID asc' + @eol
		set @fullscript = @fullscript + ') x' + @eol + @eol
			
		set @fullscript = @fullscript + 'if @MaxOldID is null' + @eol
		set @fullscript = @fullscript + '	break' + @eol + @eol
				
		set @fullscript = @fullscript + '--#DEBUG select MinOldID=@MinOldID, MaxOldID=@MaxOldID' + @eol

		set @txt = '' 

		select @txt = @txt + @eol + @tab + c.name + ','
		from sys.all_columns c
		join sys.types t on c.user_type_id = t.user_type_id
		where c.object_id = @auditobjectid
		order by c.column_id

	   	set @fullscript =  @fullscript + @eol + 'insert into ' + @fullauditclone + @eol + '(' + left(@txt, len(@txt)-1) + @eol + ')' + @eol

		set @txt = '' 

		select @txt = @txt + @eol + 
			@tab + case when c.name = @identitycol then @identitycol + ' = map.NewID' else 'tab.' + c.name end + ','
		from sys.all_columns c
		join sys.types t on c.user_type_id = t.user_type_id
		where c.object_id = @auditobjectid
		order by c.column_id

	   	set @fullscript =  @fullscript + 'select' + left(@txt, len(@txt)-1) + @eol +
 			'from ' + @mapalias + ' map' + @eol +
			'join ' + @fullaudit + ' tab with (forceseek) on map.OldID = tab.' + @identitycol + @eol +
			'where map.OldID between @MinOldID and @MaxOldID' + @eol
		
		set @fullscript =  @fullscript + @eol + 'set @MinOldID = @MaxOldID + 1' + @eol
	
	 	set @eol = @eol_normal
		
 	   	set @fullscript =  @fullscript + @eol + 'end' + @eol
		
	   	set @fullscript =  @fullscript + @eol + 'select datediff(Second, @StartTime, GetDate()) as ''Fill ' + @auditclone + ' (Seconds)''' + @eol + @goline

		set @fullscript =  @fullscript + 
			'--#DEBUG select count(*) as ' + @audittable + 'Count from ' + @fullaudit + @eol +
			'--#DEBUG select count(*) as ' + @auditclone + 'Count, min(' + @identitycol + ') as Min' + @identitycol + '_Audit from ' + @fullauditclone + @eol +
			'--#DEBUG select top 10 * from ' + @fullauditclone + @eol + @goline
	end

	--set @fullscript =  @fullscript + 
	--	'declare @StartTime datetime = GetDate()' + @eol +
	--	'alter database ' + @dbname + ' set recovery full;' + @eol +
	--	'select datediff(Second, @StartTime, GetDate()) as ''Set database recovery mode as full (Seconds)''' + @eol +
	--	'select EndTime = GetDate()' + @eol + @goline

	--set @fullscript =  @fullscript + 
	--	'declare @StartTime datetime = GetDate()' + @eol +
	--	'select RunOption = ''Rename tables'', StartTime = @StartTime' + @eol +
	--	'alter database ' + @dbname + ' set recovery simple;' + @eol +
	--	'select datediff(Second, @StartTime, GetDate()) as ''Set database recovery mode as simple (Seconds)''' + @eol +
	--	@goline

	--set @fullscript =  @fullscript + 
	--	'-- Will now only use ' + @mapalias + ' for update so remove rows where NewID = OldID' + @eol +
	--	'delete from ' + @mapalias + ' where NewID = OldID' + @eol + @goline

	exec APXSys.pRenameCloneToOriginal @clone = @fullclone, @mapalias = @mapalias, @tableobjectid = @tableobjectid, @partscript = @partscript output;

	set @fullscript = @fullscript + @partscript;

	if @auditobjectid is not null
	begin
		exec APXSys.pRenameCloneToOriginal @clone = @fullauditclone, @mapalias = @mapalias, @tableobjectid = @auditobjectid, @partscript = @partscript output;
		set @fullscript = @fullscript + @partscript;
	end

	set @fullscript =  @fullscript +
	'declare @mapdb sysname = db_name()' + @eol + @eol +

	'if exists (select * from sys.databases where name = db_name() + ''_Temp'')' + @eol + 
	'	set @mapdb = @mapdb + ''_Temp''' + @eol + @eol +

	'exec (''if object_ID(''''' + @mapalias + ''''') is not null drop synonym ' + @mapalias + ''')' + @eol +
	'exec (''if object_ID('''''' + @mapdb + ''.' + @maptable + ''''') is not null drop table '' + @mapdb + ''.' + @maptable + ''')' + @eol + @goline

	--set @fullscript =  @fullscript + @eol + 
	--	'if object_ID(''' + @maptable + ''') is not null drop table ' + @maptable + @eol + @goline

	set @fullscript =  @fullscript + 
		'exec dbo.pAoInstShrinkLog' + @eol + @goline + 
		'declare @StartTime datetime = GetDate()' + @eol +
		'alter database ' + @dbname + ' set recovery full;' + @eol +
		'--#DEBUG select datediff(Second, @StartTime, GetDate()) as ''Set database recovery mode as full (Seconds)''' + @eol + @goline +
		'select EndTime = GetDate()' + @eol + @goline

	execute APXSys.pPrint @fullscript

end try
begin catch
	execute APX.pRethrowError;
end catch
go

--exec APXSys.pGenerateScriptToRemoveIdentityGaps @dbname = 'LuminousAPXFirm_5_02', @schema = 'APX', @table = 'PerformanceSecurity'
--exec APXSys.pGenerateScriptToRemoveIdentityGaps @dbname = 'LuminousAPXFirm_5_02', @schema = 'APX', @table = 'Performance'
--exec APXSys.pGenerateScriptToRemoveIdentityGaps @dbname = 'APXFirmTrial', @schema = 'APX', @table = 'PerformanceSecurity'
--exec APXSys.pGenerateScriptToRemoveIdentityGaps @dbname = 'APXFirmNext', @schema = 'dbo', @table = 'AdvPortfolioTransaction'	-- DON'T KNOW WHY THIS IS HERE...WON'T WORK, FK FROM OTHER TABLES AREN'T UPDATED!!
--exec APXSys.pGenerateScriptToRemoveIdentityGaps @dbname = 'APXFirmTrial', @schema = 'dbo', @table = 'AdvSecurity'				-- DON'T KNOW WHY THIS IS HERE...WON'T WORK, FK FROM OTHER TABLES AREN'T UPDATED!!

