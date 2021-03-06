if object_id('tempdb..#Masterfile') is not null drop table #Masterfile
SELECT RIGHT(BAC,6) as bac, SERVICE_REGION_NAME as region, SERVICE_ZONE_NAME as zone, SERVICE_AREA_NAME as district
INTO #Masterfile
FROM GM_Reorg.dbo.GM_MASTERFILE_BY_ROOFTOP
WHERE REPORT_PERIOD_NEW = (SELECT MAX(dateEnd) FROM GM_Dynamic.dbo.SSORetentionCurrentView)
AND OPENPT_FLAG = 'N'


if object_id('tempdb..#SSOAccess') is not null drop table #SSOAccess
SELECT ISNULL(region,'NATIONAL') AS region, zone, district
	, m.bac, dbo.Divide_Decimal(COUNT(s.BAC), COUNT(m.bac)) AS SSOAccess
INTO #SSOAccess
FROM #Masterfile m
LEFT JOIN  GM_Data_Processing.dbo.SSORetention_RollupExtract s
ON m.bac = RIGHT(s.BAC,6)
AND EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND s.Division = 'ROOFTOP'
GROUP BY GROUPING SETS(
	(region, zone, district, m.bac),
	(region, zone, district),
	(region, zone),
	(region),
	()
)
--select * from #SSOAccess


if object_id('tempdb..#ServiceRetention') is not null drop table #ServiceRetention
SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100 as dealerValue, CONVERT(decimal(20,10),DISTRICT_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100 as fieldValue, 4 as fieldCompAvgID, 36 as metricNameID
INTO #ServiceRetention
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),ZONE_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, 3, 36
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),REGION_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, 2, 36
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),NATION_New_13to72_Retention_Percent_DealerSoldInAGSSA)*100, 1, 36
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),DISTRICT_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, 4, 35
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),ZONE_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, 3, 35
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),REGION_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, 2, 35 
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT RIGHT(BAC,6) as BAC, CONVERT(decimal(20,10),AGSSA_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, CONVERT(decimal(20,10),NATION_New_7to12_Retention_Percent_DealerSoldInAGSSA)*100, 1, 35
FROM GM_Data_Processing.dbo.SSORetention_RollupExtract
WHERE EndDate = (SELECT MAX(EndDate) FROM GM_Data_Processing.dbo.SSORetention_RollupExtract)
AND Division = 'ROOFTOP'
UNION SELECT d.bac, d.SSOAccess, ROUND(f.SSOAccess,3)*100, 4, 16
FROM #SSOAccess d
LEFT JOIN #SSOAccess f
ON d.district = f.district AND d.zone = f.zone AND d.region = f.region
WHERE d.bac IS NOT NULL AND f.bac IS NULL
UNION SELECT d.bac, d.SSOAccess, ROUND(f.SSOAccess,3)*100, 3, 16
FROM #SSOAccess d
LEFT JOIN #SSOAccess f
ON d.zone = f.zone AND d.region = f.region
WHERE d.bac IS NOT NULL AND f.district IS NULL
UNION SELECT d.bac, d.SSOAccess, ROUND(f.SSOAccess,3)*100, 2, 16
FROM #SSOAccess d
LEFT JOIN #SSOAccess f
ON d.region = f.region
WHERE d.bac IS NOT NULL AND f.zone IS NULL
UNION SELECT d.bac, d.SSOAccess, ROUND(f.SSOAccess,3)*100, 1, 16
FROM #SSOAccess d
LEFT JOIN #SSOAccess f
ON f.region = 'NATIONAL'
WHERE d.bac IS NOT NULL


/**************************
Update DART Tables
***************************/

DELETE FROM dbo.BDCMetricMetrics WHERE metricNameID IN (16,35,36)

if object_id('tempdb..#DealerInfo') is not null drop table #DealerInfo
select bac, region, m.zone as serviceZone, serviceDistrict, metricNameID 
INTO #DealerInfo 
from dbo.BDCMetricDealerInfo d
LEFT JOIN (
	SELECT DISTINCT zone, district
	FROM DPRSRVDealerPerformanceHeaderData
)m
ON d.serviceDistrict = m.district
cross join (
	select metricNameID 
	from dbo.BDCMetricMetricName
	WHERE metricNameID IN (16,35,36)
) metric


INSERT INTO dbo.BDCMetricMetrics(bac, metricNameID, marketCompID, value, valueRGB, marketCompAvg, timePeriod)
SELECT d.bac, d.metricNameID, c.marketCompID
	, CASE WHEN d.metricNameID IN(
			35/*Retention 7-12*/
			,36/*Retention 13-72*/) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1),  s.dealerValue))+'%'),'-')
		WHEN d.metricNameID IN(16/*ServiceSmarts*/) AND s.dealerValue = 1 THEN 'Y'
		WHEN d.metricNameID IN(16/*ServiceSmarts*/) AND s.dealerValue <> 1 THEN 'N'
		END AS value
	, CASE WHEN d.metricNameID IN(35,36) AND s.dealerValue < s.fieldValue THEN '244,186,186'
		WHEN d.metricNameID IN(35,36) AND s.dealerValue >= s.fieldValue THEN '226,240,217'
		WHEN d.metricNameID IN(16) AND s.dealerValue <> 1 THEN '244,186,186'
		WHEN d.metricNameID IN(16) AND s.dealerValue = 1 THEN '226,240,217'
		ELSE '255,255,255' 
		END AS valueRGB		
	, CASE WHEN d.metricNameID IN(
			16/*ServiceSmarts*/
			,35/*Retention 7-12*/
			,36/*Retention 13-72*/
			) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1),  s.fieldValue))+'%'),'-')
		END AS marketCompAvg
	, tp.timePeriod	
FROM #DealerInfo d
CROSS JOIN dbo.BDCMetricMarketComparison c
LEFT JOIN #ServiceRetention s
ON d.bac = s.BAC and d.metricNameID = s.metricNameID and s.fieldCompAvgID = c.marketCompID
CROSS JOIN (SELECT MAX(timePeriod) as timePeriod from dbo.BDCMetricMetrics) tp



/**************************
Footnotes
***************************/
--SELECT * FROM dbo.BDCMetricFootnote 

if object_id('tempdb..#DataSources') is not null drop table #DataSources
create table #DataSources
(
  metric varchar(100) NULL,
  dataSource varchar(100) NULL,
  reportPeriod date NULL,
  orderID int NULL
)

insert into #DataSources select 'Service Retention','ServiceSmarts Online', MAX(EndDate), 11 from GM_Data_Processing.dbo.SSORetention_RollupExtract

DELETE FROM dbo.BDCMetricFootnote WHERE footnoteName IN('Service Retention')
INSERT INTO dbo.BDCMetricFootnote (footnoteType, footnoteName, footnoteText, footnoteDate)
select 
	'Footer'
	, metric
	, metric + ' Data Source: ' + dataSource + '  '
	, DATENAME(MONTH, reportPeriod) + ' ' + convert(varchar(4),YEAR(reportPeriod))
from #DataSources




/**************************
Resources
***************************/

--Need to modify mappings if new metrics are added
if object_id('tempdb..#ResourceMetricMap') is not null drop table #ResourceMetricMap
select 1 AS resourceLinkID, 4 AS metricNameID
into #ResourceMetricMap
union select 2,6
union select 3,8
union select 4,10
union select 5,12
union select 6,17
union select 7,22
union select 8,23
union select 9,24
union select 10,26
union select 11,29
union select 12,30
union select 13,31
union select 14,35
union select 15,36


if object_id('tempdb..#ResourceMetricCombined') is not null drop table #ResourceMetricCombined
select m.metricNameID, m.metricName, r.resourceLinkID, r.resourceHTML 
into #ResourceMetricCombined
from dbo.BDCMetricMetricName m
join #ResourceMetricMap mr
on m.metricNameID = mr.metricNameID
join dbo.BDCMetricResourceLinks r
on mr.resourceLinkID = r.resourceLinkID



DELETE FROM dbo.BDCMetricResources WHERE resourceLinkID IN (SELECT resourceLinkID FROM #ResourceMetricCombined WHERE metricNameID IN (35,36))

if object_id('tempdb..#BDCMetricMetricsService') is not null drop table #BDCMetricMetricsService
SELECT bac, metricNameID, marketCompID, value, marketCompAvg
INTO #BDCMetricMetricsService 
FROM dbo.BDCMetricMetrics 
WHERE metricNameID IN (35,36)

--Populate Resources
INSERT INTO dbo.BDCMetricResources (resourceLinkID, marketCompID, bac)
SELECT r.resourceLinkID, m.marketCompID, m.bac
FROM #BDCMetricMetricsService m
JOIN #ResourceMetricCombined r
ON m.metricNameID = r.metricNameID
WHERE m.metricNameID IN (35,36) AND m.value < m.marketCompAvg AND m.value <> '-'


--Populate orderID
UPDATE r
SET orderID = orderIDUpdate
FROM dbo.BDCMetricResources r
JOIN (
	SELECT *, row_number()over(partition by bac, marketCompID order by resourceLinkID) as orderIDUpdate
	FROM dbo.BDCMetricResources
) rr
ON r.resourceID = rr.resourceID 




if object_id('tempdb..#MetricToolTip') is not null drop table #MetricToolTip
SELECT t.metricNameID, t.metricName, t.metricTooltip
INTO #MetricToolTip
FROM dbo.BDCMetricMetricTooltip t
JOIN dbo.BDCMetricMetricName n ON t.metricNameID = n.metricNameID
					
--Service Smarts
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 16) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Service Retention'))
WHERE metricNameID = 16
			
--Retention 7-12
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 35) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Service Retention'))
WHERE metricNameID = 35

--Retention 13-72
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 36) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Service Retention'))
WHERE metricNameID = 36
