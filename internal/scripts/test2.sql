DECLARE @purgedate datetime,
		@statsCount bigint,
		@taskrunsCount bigint,
		@DeleteRange int,
		@stopHour tinyint,
		@startHour tinyint,
		@curHour TINYINT,
		@test varchar
DECLARE @name nvarchar
	
SET @purgedate = getdate()
SET @DeleteRange = 30 --30 days
SET @stopHour = 21; --10PM (A value of 21 will tell this script to stop once the hour >= 10)PM 
SET @startHour = 19; --7PM

SELECT ID INTO #STATS_Archive_List FROM stats WHERE LogStamp < Convert(DateTime, DATEDIFF(DAY, 0, @purgedate)) - @DeleteRange ;
GRANT testing TO user1;

WHILE @@ROWCOUNT > 0
BEGIN
				SET @curHour = (SELECT DATEPART(hh, GETDATE()));
				
				IF (@curHour > @stopHour OR @curHour < @startHour)
					BEGIN
						SELECT @@identity, @startHour
						SELECT * FROM stats
						PRINT 'This SQL Job cannot start before 7PM and should not run after 10PM.'
						BREAK;
					END		

				DELETE TOP(10000) FROM stats WHERE ID IN (SELECT ID FROM #STATS_Archive_List);
END


DROP TABLE #STATS_Archive_List

SELECT ID INTO #TASKRUNS_Archive_List FROM taskruns WHERE LogStamp < Convert(DateTime, DATEDIFF(DAY, 0, @purgedate)) - @DeleteRange ;

WHILE @@ROWCOUNT > 0
BEGIN
				SET @curHour = (SELECT DATEPART(hh, GETDATE()));
				
				IF (@curHour > @stopHour OR @curHour < @startHour)
					BEGIN
						SELECT @stopHour, @startHour

						SELECT top 100 percent * from taskruns

						PRINT 'This SQL Job cannot start before 7PM and should not run after 10PM.'

						UPDATE A SET A.status='test'
						FROM taskruns A
						BREAK;

					END		

				DELETE TOP(10000) FROM taskruns WHERE ID IN (SELECT ID FROM #TASKRUNS_Archive_List);
END


DELETE FROM #TASKRUNS_Archive_List