		
		
	--Lines below is used to avoid "forreign key" error when updating.
	Begin Transaction
	exec APXFirm..pAdvAuditEventBegin @userID = -1001, @functionID=24; -- Manual change
	commit transaction	
	
		--update apxFirm..advPortfolioProperty 
		set propertyvalue = '\\VSACAXAPP10-1\Data\utils\GenericDates\'
		where propertyvalue = '\\sacmhfs10\Data\utils\GenericDates\'
		
	Begin Transaction	
	exec APXFirm..pAdvAuditEventEnd;
	commit transaction


	select * from apxFirm..advPortfolioProperty 
		where propertyvalue = '\\VSACAXAPP10-1\Data\utils\GenericDates\'
		--where propertyvalue = '\\sacmhfs10\Data\utils\GenericDates\'
