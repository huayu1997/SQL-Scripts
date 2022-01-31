use apxcontroller

Select	* From vADVSDatabaseSetting Where Setting = 'MinRetentionDays'

--update vADVSDatabaseSetting
set Value = 30 where Setting = 'MinRetentionDays'