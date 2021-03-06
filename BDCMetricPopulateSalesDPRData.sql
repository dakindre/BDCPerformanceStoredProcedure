if object_id('tempdb..#DealerData') is not null drop table #DealerData
select bac, region, slsZone, slsDistrict
	, CASE metric WHEN 'visits' THEN 1
					WHEN 'visitors' THEN 2
					WHEN 'phoneCalls' THEN 3
					WHEN 'visitorConversionRate' THEN 4
					WHEN 'VDPViews' THEN 5
					WHEN 'TotalLeadVolume' THEN 6
					WHEN 'ShopClickDrive' THEN 7
					WHEN 'PhoneCallFailRate' THEN 17
					WHEN 'Unanswered' THEN 18
					WHEN 'HoldTimeAbandon' THEN 19
					WHEN 'IVRVoicemailAbandon' THEN 20
					WHEN 'RingTransferAbandon' THEN 21
					WHEN 'InternetLeadCloseRate' THEN 22
					WHEN 'RespondedTo30Min' THEN 23
					WHEN 'AverageResponseTime' THEN 24
					END AS metric	
									
	, CASE metric	WHEN 'visits' THEN visits
					WHEN 'visitors' THEN visitors
					WHEN 'phoneCalls' THEN phoneCalls
					WHEN 'visitorConversionRate' THEN visitorConversionRate
					WHEN 'VDPViews' THEN VDPViews
					WHEN 'TotalLeadVolume' THEN TotalLeadVolume
					WHEN 'ShopClickDrive' THEN ShopClickDrive
					WHEN 'PhoneCallFailRate' THEN PhoneCallFailRate
					WHEN 'Unanswered' THEN Unanswered
					WHEN 'HoldTimeAbandon' THEN HoldTimeAbandon
					WHEN 'IVRVoicemailAbandon' THEN IVRVoicemailAbandon
					WHEN 'RingTransferAbandon' THEN RingTransferAbandon
					WHEN 'InternetLeadCloseRate' THEN InternetLeadCloseRate
					WHEN 'RespondedTo30Min' THEN RespondedTo30Min
					WHEN 'AverageResponseTime' THEN AverageResponseTime
					END AS value				
INTO #DealerData
FROM (
	select bac, region, zone as slsZone, district as slsDistrict 
		, CONVERT(DECIMAL(20,10), CASE scdParticipant WHEN 'Y' THEN 1 ELSE 0 END) as ShopClickDrive
		, CONVERT(DECIMAL(20,10),totalLeads) as TotalLeadVolume
		, CONVERT(DECIMAL(20,10), ROUND(avgDealerCloseRate,3)*100) as InternetLeadCloseRate
		, CONVERT(DECIMAL(20,10), ROUND(respondedToPercent30Minutes,3)*100) as RespondedTo30Min
		, CONVERT(DECIMAL(20,10),dbo.ConvertResponseTimeToDays(avgResponseTime)) as AverageResponseTime 
		, CONVERT(DECIMAL(20,10), visits) AS visits
		, CONVERT(DECIMAL(20,10), visitors) AS visitors
		, CONVERT(DECIMAL(20,10), phoneCallsTotal) AS phoneCalls
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(phoneCallsTotalFailed, phoneCallsTotal), 3)*100) AS PhoneCallFailRate
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(phoneCallsTotalUnanswered, phoneCallsTotalFailed), 3)*100) AS Unanswered
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(phoneCallsTotalHoldTimeAbandon, phoneCallsTotalFailed), 3)*100) AS HoldTimeAbandon
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(phoneCallsTotalIVRVoicemailAbandon, phoneCallsTotalFailed), 3)*100) AS IVRVoicemailAbandon
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(phoneCallsTotalRingTransferAbandon, phoneCallsTotalFailed), 3)*100) AS RingTransferAbandon
		, CONVERT(DECIMAL(20,10), ROUND(visitorConversionRate,3)*100) AS visitorConversionRate
		, CONVERT(DECIMAL(20,10), vehicleViews) AS VDPViews
	-- select *
	from dbo.LeadReportingDDPRPerformanceDataFull
	where reportPeriod = (select max(reportPeriod) from dbo.LeadReportingDDPRPerformanceDataFull)
	and dataPeriodRank = 1
	and division = 'Total'
)p
CROSS JOIN (
	SELECT 'visits' UNION SELECT 'visitors' UNION SELECT 'phoneCalls' UNION SELECT 'PhoneCallFailRate' UNION SELECT 'Unanswered' UNION SELECT 'HoldTimeAbandon'
	UNION SELECT 'IVRVoicemailAbandon' UNION SELECT 'RingTransferAbandon' UNION SELECT 'visitorConversionRate' UNION SELECT 'VDPViews' UNION SELECT 'TotalLeadVolume'
	UNION SELECT 'ShopClickDrive' UNION SELECT 'InternetLeadCloseRate' UNION SELECT 'RespondedTo30Min' UNION SELECT 'AverageResponseTime' 
) unpvt(metric)



if object_id('tempdb..#FieldData') is not null drop table #FieldData
select region, slsZone, slsDistrict, fieldCompAvgID
	, CASE metric 
		WHEN 'visits' THEN 1
		WHEN 'visitors' THEN 2
		WHEN 'phoneCalls' THEN 3
		WHEN 'visitorConversionRate' THEN 4
		WHEN 'VDPViews' THEN 5
		WHEN 'TotalLeadVolume' THEN 6
		WHEN 'ShopClickDrive' THEN 7
		WHEN 'PhoneCallFailRate' THEN 17
		WHEN 'Unanswered' THEN 18
		WHEN 'HoldTimeAbandon' THEN 19
		WHEN 'IVRVoicemailAbandon' THEN 20
		WHEN 'RingTransferAbandon' THEN 21
		WHEN 'InternetLeadCloseRate' THEN 22
		WHEN 'RespondedTo30Min' THEN 23
		WHEN 'AverageResponseTime' THEN 24
		END AS metric					
	, value			
INTO #FieldData
FROM (
	SELECT ISNULL(region,'NATIONAL') as region, zone as slsZone, district as slsDistrict
		, case when region IS NULL then '1' 
			when zone IS NULL then '2' 
			when district IS NULL then '3' 
			else '4' 
			end as fieldCompAvgID
		, CONVERT(DECIMAL(20,10), ROUND(dbo.Divide_Decimal(SUM(CASE scdParticipant WHEN 'Y' THEN 1 END), COUNT(DISTINCT bac)),3)*100) AS ShopClickDrive
		, CONVERT(DECIMAL(20,10), ROUND(avg(convert(DECIMAL(20,10),totalLeads)),0)) as TotalLeadVolume
		, CONVERT(DECIMAL(20,10), ROUND(dbo.Divide_Decimal(SUM(uniqueHHsales),SUM(uniqueHHleads)),3)*100) AS InternetLeadCloseRate
		, CONVERT(DECIMAL(20,10), ROUND(dbo.Divide_Decimal(SUM(leadsRespondedTo30Min),SUM(totalLeads)),3)*100) AS RespondedTo30Min
		, CONVERT(DECIMAL(20,10), dbo.divide_decimal(sum(dealerRespTimeTot),SUM(leadsRespondedTo))) AS AverageResponseTime	
		, CONVERT(DECIMAL(20,10), ROUND(AVG(CONVERT(DECIMAL(20,10),visits)),0)) AS visits
		, CONVERT(DECIMAL(20,10), ROUND(AVG(CONVERT(DECIMAL(20,10),visitors)),0)) AS visitors
		, CONVERT(DECIMAL(20,10), ROUND(AVG(CONVERT(DECIMAL(20,10),phoneCallsTotal)),0)) AS phoneCalls
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(SUM(phoneCallsTotalFailed), sum(phoneCallsTotal)), 3)*100) AS PhoneCallFailRate
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(SUM(phoneCallsTotalUnanswered), sum(phoneCallsTotalFailed)), 3)*100) AS Unanswered
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(SUM(phoneCallsTotalHoldTimeAbandon), sum(phoneCallsTotalFailed)), 3)*100) AS HoldTimeAbandon
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(SUM(phoneCallsTotalIVRVoicemailAbandon), sum(phoneCallsTotalFailed)), 3)*100) AS IVRVoicemailAbandon
		, CONVERT(DECIMAL(20,10), ROUND(GM_Special_Projects.dbo.Divide_Decimal(SUM(phoneCallsTotalRingTransferAbandon), sum(phoneCallsTotalFailed)), 3)*100) AS RingTransferAbandon
		, CONVERT(DECIMAL(20,10), ROUND(dbo.Divide_Decimal(sum(isnull(emailLeads,0)+isnull(phoneCalls,0)+isnull(hdVisits,0)),sum(visitors)),3)*100) AS visitorConversionRate
		, CONVERT(DECIMAL(20,10), ROUND(AVG(CONVERT(DECIMAL(20,10),vehicleViews)),0)) AS VDPViews
	-- select * 
	from dbo.LeadReportingDDPRPerformanceDataFull r
	where reportPeriod = (select max(reportPeriod) from dbo.LeadReportingDDPRPerformanceDataFull)
	and dataPeriodRank = 1
	and division = 'Total'
	group by grouping sets(
		(region, zone, district),
		(region, zone),
		(region),
		()
	)
)p
unpivot (value for metric IN (ShopClickDrive, visits, visitors, phoneCalls, PhoneCallFailRate, Unanswered, HoldTimeAbandon, IVRVoicemailAbandon, RingTransferAbandon, visitorConversionRate, VDPViews, TotalLeadVolume, InternetLeadCloseRate, RespondedTo30Min, AverageResponseTime)) unpvt


--Update Dealer Header Info
UPDATE d
SET thirdPartyLeads = tplParticipant
	, shopClickDrive = scdParticipant
	, salesCloseRateRnk = districtRank
--SELECT *
FROM dbo.BDCMetricDealerInfo d
LEFT JOIN (
	select bac, tplParticipant, scdParticipant
	from dbo.LeadReportingDDPRPerformanceDataFull
	where reportPeriod = (select max(reportPeriod) from dbo.LeadReportingDDPRPerformanceDataFull)
	and dataPeriodRank = 1
	and division = 'Total'
)l ON d.bac = l.bac
LEFT JOIN (
	SELECT bac, districtRank FROM dbo.LeadReportingDDPRPerformanceDataFull
	WHERE reportPeriod = (SELECT MAX(reportPeriod) FROM dbo.LeadReportingDDPRPerformanceDataFull)
	AND division = 'Total'
	AND dataPeriodRank = 1 
)s ON s.bac = d.bac 

			
					
					
DELETE FROM dbo.BDCMetricMetrics WHERE metricNameID IN (1,2,3,4,5,6,7,17,18,19,20,21,22,23,24)

if object_id('tempdb..#DealerInfo') is not null drop table #DealerInfo
select bac, region, salesZone,salesDistrict, metricNameID 
INTO #DealerInfo 
from dbo.BDCMetricDealerInfo 
cross join (
	select metricNameID 
	from dbo.BDCMetricMetricName
	WHERE metricNameID IN (1,2,3,4,5,6,7,17,18,19,20,21,22,23,24)
) metric


--District
INSERT INTO dbo.BDCMetricMetrics(bac, metricNameID, marketCompID, value, valueRGB, marketCompAvg, timePeriod)
SELECT d.bac, d.metricNameID, field.fieldCompAvgID
	, CASE WHEN d.metricNameID IN(
				1/*Visits*/
				,2/*Visitors*/
				,3/*Phone Calls*/
				,5/*VDP Views*/
				,6/*Total Lead Volume*/) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, deal.value) AS MONEY), 1), '.00', ''), '-')
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 1 THEN 'Y'
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 0 THEN 'N'
		WHEN d.metricNameID IN(
				4/*Visitor Conversion Rate*/
				,17/*Dealership Phone Call Fail Rate*/
				,18/*Unanswered*/
				,19/*Hold-Time Abandon*/
				,20/*IVR/Voicemail Abandon*/
				,21/*Ring Transfer Abandon*/
				,22/*Internet Lead Close Rate*/
				,23/*% Responded To Within 30*/
				)THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), deal.value))+'%'),'-')
		WHEN d.metricNameID IN(24/*Average Response Time*/) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(deal.value)), '-')
		ELSE CONVERT(VARCHAR(20), deal.value)
		END AS DealerValue
	, CASE WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value < field.value THEN '244,186,186'
		WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value >= field.value THEN '226,240,217'
		WHEN d.metricNameID IN(17, 24) AND deal.value >= field.value THEN '244,186,186'
		WHEN d.metricNameID IN(17, 24) AND deal.value < field.value THEN '226,240,217'
		ELSE '255,255,255' END AS MetricRGB
	, CASE WHEN field.metric IN(1, 2, 3, 5, 6) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, field.value) AS MONEY), 1), '.00', ''), '-')
		WHEN field.metric IN(4, 7, 17, 18, 19, 20, 21, 22, 23) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), field.value))+'%'),'-')
		WHEN field.metric IN(24) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(field.value)),'-')
		ELSE CONVERT(VARCHAR(20), field.value)
		END AS FieldValue
	, tp.timePeriod
FROM #DealerInfo d
LEFT JOIN #DealerData deal
ON d.bac = deal.bac	AND d.region = deal.region AND d.salesZone = deal.slsZone AND d.salesDistrict = deal.slsDistrict
	AND d.metricNameID = deal.metric
LEFT JOIN #FieldData field 
ON d.region = field.region
	AND d.salesZone = field.slsZone 
	AND d.salesDistrict = field.slsDistrict 
	AND d.metricNameID = field.metric
CROSS JOIN (SELECT MAX(timePeriod) as timePeriod from dbo.BDCMetricMetrics) tp


--Zone
INSERT INTO dbo.BDCMetricMetrics(bac, metricNameID, marketCompID, value, valueRGB, marketCompAvg, timePeriod)
SELECT d.bac, d.metricNameID, field.fieldCompAvgID
			, CASE WHEN d.metricNameID IN(
				1/*Visits*/
				,2/*Visitors*/
				,3/*Phone Calls*/
				,5/*VDP Views*/
				,6/*Total Lead Volume*/) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, deal.value) AS MONEY), 1), '.00', ''), '-')
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 1 THEN 'Y'
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 0 THEN 'N'
		WHEN d.metricNameID IN(
				4/*Visitor Conversion Rate*/
				,17/*Dealership Phone Call Fail Rate*/
				,18/*Unanswered*/
				,19/*Hold-Time Abandon*/
				,20/*IVR/Voicemail Abandon*/
				,21/*Ring Transfer Abandon*/
				,22/*Internet Lead Close Rate*/
				,23/*% Responded To Within 30*/
				)THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), deal.value))+'%'),'-')
		WHEN d.metricNameID IN(24/*Average Response Time*/) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(deal.value)), '-')
		ELSE CONVERT(VARCHAR(20), deal.value)
		END AS DealerValue
	, CASE WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value < field.value THEN '244,186,186'
		WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value >= field.value THEN '226,240,217'
		WHEN d.metricNameID IN(17, 24) AND deal.value >= field.value THEN '244,186,186'
		WHEN d.metricNameID IN(17, 24) AND deal.value < field.value THEN '226,240,217'
		ELSE '255,255,255' END AS MetricRGB
	, CASE WHEN field.metric IN(1, 2, 3, 5, 6) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, field.value) AS MONEY), 1), '.00', ''), '-')
		WHEN field.metric IN(4, 7, 17, 18, 19, 20, 21, 22, 23) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), field.value))+'%'),'-')
		WHEN field.metric IN(24) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(field.value)),'-')
		ELSE CONVERT(VARCHAR(20), field.value)
		END AS FieldValue
	, tp.timePeriod
FROM #DealerInfo d
LEFT JOIN #DealerData deal
ON d.bac = deal.bac	AND d.region = deal.region AND d.salesZone = deal.slsZone AND d.salesDistrict = deal.slsDistrict
	AND d.metricNameID = deal.metric
LEFT JOIN #FieldData field 
ON d.region = field.region
	AND d.salesZone = field.slsZone 
	AND d.metricNameID = field.metric
CROSS JOIN (SELECT MAX(timePeriod) as timePeriod from dbo.BDCMetricMetrics) tp
WHERE field.slsDistrict IS NULL


--Region
INSERT INTO dbo.BDCMetricMetrics(bac, metricNameID, marketCompID, value, valueRGB, marketCompAvg, timePeriod)
SELECT d.bac, d.metricNameID, field.fieldCompAvgID
		, CASE WHEN d.metricNameID IN(
				1/*Visits*/
				,2/*Visitors*/
				,3/*Phone Calls*/
				,5/*VDP Views*/
				,6/*Total Lead Volume*/) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, deal.value) AS MONEY), 1), '.00', ''), '-')
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 1 THEN 'Y'
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 0 THEN 'N'
		WHEN d.metricNameID IN(
				4/*Visitor Conversion Rate*/
				,17/*Dealership Phone Call Fail Rate*/
				,18/*Unanswered*/
				,19/*Hold-Time Abandon*/
				,20/*IVR/Voicemail Abandon*/
				,21/*Ring Transfer Abandon*/
				,22/*Internet Lead Close Rate*/
				,23/*% Responded To Within 30*/
				)THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), deal.value))+'%'),'-')
		WHEN d.metricNameID IN(24/*Average Response Time*/) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(deal.value)), '-')
		ELSE CONVERT(VARCHAR(20), deal.value)
		END AS DealerValue
	, CASE WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value < field.value THEN '244,186,186'
		WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value >= field.value THEN '226,240,217'
		WHEN d.metricNameID IN(17, 24) AND deal.value >= field.value THEN '244,186,186'
		WHEN d.metricNameID IN(17, 24) AND deal.value < field.value THEN '226,240,217'
		ELSE '255,255,255' END AS MetricRGB
	, CASE WHEN field.metric IN(1, 2, 3, 5, 6) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, field.value) AS MONEY), 1), '.00', ''), '-')
		WHEN field.metric IN(4, 7, 17, 18, 19, 20, 21, 22, 23) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), field.value))+'%'),'-')
		WHEN field.metric IN(24) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(field.value)),'-')
		ELSE CONVERT(VARCHAR(20), field.value)
		END AS FieldValue
	, tp.timePeriod
FROM #DealerInfo d
LEFT JOIN #DealerData deal
ON d.bac = deal.bac	AND d.region = deal.region AND d.salesZone = deal.slsZone AND d.salesDistrict = deal.slsDistrict
	AND d.metricNameID = deal.metric
LEFT JOIN #FieldData field 
ON d.region = field.region
	AND d.metricNameID = field.metric
CROSS JOIN (SELECT MAX(timePeriod) as timePeriod from dbo.BDCMetricMetrics) tp
WHERE field.slsZone IS NULL


--National
INSERT INTO dbo.BDCMetricMetrics(bac, metricNameID, marketCompID, value, valueRGB, marketCompAvg, timePeriod)
SELECT d.bac, d.metricNameID, field.fieldCompAvgID
		, CASE WHEN d.metricNameID IN(
				1/*Visits*/
				,2/*Visitors*/
				,3/*Phone Calls*/
				,5/*VDP Views*/
				,6/*Total Lead Volume*/) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, deal.value) AS MONEY), 1), '.00', ''), '-')
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 1 THEN 'Y'
		WHEN d.metricNameID IN(
				7/*Shop-Click-Drive*/) AND deal.value = 0 THEN 'N'
		WHEN d.metricNameID IN(
				4/*Visitor Conversion Rate*/
				,17/*Dealership Phone Call Fail Rate*/
				,18/*Unanswered*/
				,19/*Hold-Time Abandon*/
				,20/*IVR/Voicemail Abandon*/
				,21/*Ring Transfer Abandon*/
				,22/*Internet Lead Close Rate*/
				,23/*% Responded To Within 30*/
				)THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), deal.value))+'%'),'-')
		WHEN d.metricNameID IN(24/*Average Response Time*/) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(deal.value)), '-')
		ELSE CONVERT(VARCHAR(20), deal.value)
		END AS DealerValue
	, CASE WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value < field.value THEN '244,186,186'
		WHEN d.metricNameID IN(4, 6, 22, 23) AND deal.value >= field.value THEN '226,240,217'
		WHEN d.metricNameID IN(17, 24) AND deal.value >= field.value THEN '244,186,186'
		WHEN d.metricNameID IN(17, 24) AND deal.value < field.value THEN '226,240,217'
		ELSE '255,255,255' END AS MetricRGB
	, CASE WHEN field.metric IN(1, 2, 3, 5, 6) THEN ISNULL(REPLACE(CONVERT(VARCHAR(20), CAST(CONVERT(INT, field.value) AS MONEY), 1), '.00', ''), '-')
		WHEN field.metric IN(4, 7, 17, 18, 19, 20, 21, 22, 23) THEN ISNULL((CONVERT(VARCHAR(20), CONVERT(DECIMAL(10,1), field.value))+'%'),'-')
		WHEN field.metric IN(24) THEN ISNULL(CONVERT(VARCHAR(20), dbo.ConvertResponseDaysToTime(field.value)),'-')
		ELSE CONVERT(VARCHAR(20), field.value)
		END AS FieldValue
	, tp.timePeriod
FROM #DealerInfo d
LEFT JOIN #DealerData deal
ON d.bac = deal.bac	AND d.region = deal.region AND d.salesZone = deal.slsZone AND d.salesDistrict = deal.slsDistrict
	AND d.metricNameID = deal.metric
LEFT JOIN #FieldData field 
ON d.metricNameID = field.metric
CROSS JOIN (SELECT MAX(timePeriod) as timePeriod from dbo.BDCMetricMetrics) tp
WHERE field.region = 'NATIONAL'



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

insert into #DataSources select 'Sales Leads','GM', MAX(reportPeriod), 7 from dbo.LeadReportingDDPRPerformanceDataFull
insert into #DataSources select 'Website','CDK', MAX(reportPeriod), 8 from dbo.LeadReportingDDPRPerformanceDataFull
insert into #DataSources select 'Phone Call', 'MarchEx', MAX(reportPeriod), 12 from dbo.LeadReportingDDPRPerformanceDataFull


DELETE FROM dbo.BDCMetricFootnote WHERE footnoteName IN ('Sales Leads', 'Website', 'Phone Call')
INSERT INTO dbo.BDCMetricFootnote (footnoteType, footnoteName, footnoteText, footnoteDate)
select 
	'Footer'
	, metric
	, metric + ' Data Source: ' + dataSource + '  '
	, DATENAME(MONTH, reportPeriod) + ' ' + convert(varchar(4),YEAR(reportPeriod))
from #DataSources




/****Populate Resource Links****/

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

--SELECT * FROM #ResourceMetricMap



if object_id('tempdb..#ResourceMetricCombined') is not null drop table #ResourceMetricCombined
select m.metricNameID, m.metricName, r.resourceLinkID, r.resourceHTML
into #ResourceMetricCombined
from dbo.BDCMetricMetricName m
join #ResourceMetricMap mr
on m.metricNameID = mr.metricNameID
join dbo.BDCMetricResourceLinks r
on mr.resourceLinkID = r.resourceLinkID


DELETE FROM dbo.BDCMetricResources WHERE resourceLinkID IN (SELECT resourceLinkID FROM #ResourceMetricCombined WHERE metricNameID IN (1,2,6,7,8,9))

/**Populate resources for DISTRICT avg. comparisons**/
INSERT INTO dbo.BDCMetricResources (resourceLinkID, marketCompID, bac)
SELECT CASE WHEN r.resourceLinkID in (1,2,7,8) and deal.value < field.value THEN r.resourceLinkID
			WHEN r.resourceLinkID in (6,9) and deal.value > field.value THEN r.resourceLinkID 
		END AS resourceLinkID
	, field.fieldCompAvgID
	, deal.bac
FROM #ResourceMetricCombined r
JOIN #DealerData deal ON r.metricNameID = deal.metric
LEFT JOIN #FieldData field ON deal.region = field.region 
	AND deal.slsZone = field.slsZone 
	AND deal.slsDistrict = field.slsDistrict
	AND deal.metric = field.metric
WHERE (r.resourceLinkID in (1,2,7,8) and deal.value < field.value)
	OR (r.resourceLinkID in (6,9) and deal.value > field.value)



/**Populate resources for ZONE avg. comparisons**/
INSERT into dbo.BDCMetricResources (resourceLinkID, marketCompID, bac)
SELECT CASE WHEN r.resourceLinkID in (1,2,7,8) and deal.value < field.value THEN r.resourceLinkID
			WHEN r.resourceLinkID in (6,9) and deal.value > field.value THEN r.resourceLinkID 
		END AS resourceLinkID
	, field.fieldCompAvgID
	, deal.bac
FROM #ResourceMetricCombined r
JOIN #DealerData deal ON r.metricNameID = deal.metric
LEFT JOIN #FieldData field ON deal.region = field.region 
	AND deal.slsZone = field.slsZone 
	AND deal.metric = field.metric
WHERE field.slsDistrict IS NULL
AND ((r.resourceLinkID in (1,2,7,8) and deal.value < field.value)
	OR (r.resourceLinkID in (6,9) and deal.value > field.value))


/**Populate resources for REGION avg. comparisons**/
INSERT into dbo.BDCMetricResources (resourceLinkID, marketCompID, bac)
SELECT CASE WHEN r.resourceLinkID in (1,2,7,8) and deal.value < field.value THEN r.resourceLinkID
			WHEN r.resourceLinkID in (6,9) and deal.value > field.value THEN r.resourceLinkID 
		END AS resourceLinkID
	, field.fieldCompAvgID
	, deal.bac
FROM #ResourceMetricCombined r
JOIN #DealerData deal ON r.metricNameID = deal.metric
LEFT JOIN #FieldData field ON deal.region = field.region  
	AND deal.metric = field.metric
WHERE field.slsDistrict IS NULL
AND field.slsZone IS NULL
AND ((r.resourceLinkID in (1,2,7,8) and deal.value < field.value)
	OR (r.resourceLinkID in (6,9) and deal.value > field.value))



/**Populate resources for NATIONAL avg. comparisons**/
INSERT into dbo.BDCMetricResources (resourceLinkID, marketCompID, bac)
SELECT CASE WHEN r.resourceLinkID in (1,2,7,8) and deal.value < field.value THEN r.resourceLinkID
			WHEN r.resourceLinkID in (6,9) and deal.value > field.value THEN r.resourceLinkID 
		END AS resourceLinkID
	, field.fieldCompAvgID
	, deal.bac
FROM #ResourceMetricCombined r
JOIN #DealerData deal ON r.metricNameID = deal.metric
LEFT JOIN #FieldData field ON deal.metric = field.metric
WHERE field.region = 'NATIONAL'
AND ((r.resourceLinkID in (1,2,7,8) and deal.value < field.value)
	OR (r.resourceLinkID in (6,9) and deal.value > field.value))


--Populate orderID
UPDATE r
SET orderID = orderIDUpdate
FROM dbo.BDCMetricResources r
JOIN (
	SELECT *, row_number()over(partition by bac, marketCompID order by resourceLinkID) as orderIDUpdate
	FROM dbo.BDCMetricResources
) rr
ON r.resourceID = rr.resourceID 


/***********************************
 Update Metric ToolTips With Date
***********************************/

if object_id('tempdb..#MetricToolTip') is not null drop table #MetricToolTip
SELECT t.metricNameID, t.metricName, t.metricTooltip
INTO #MetricToolTip
FROM dbo.BDCMetricMetricTooltip t
JOIN dbo.BDCMetricMetricName n ON t.metricNameID = n.metricNameID
					
				
--Visits
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 1) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Website'))
WHERE metricNameID = 1

--Visitors
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 2) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Website'))
WHERE metricNameID = 2

--Phone Calls
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 3) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 3

--Visitor Conversion Rate
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 4) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Website'))
WHERE metricNameID = 4

--VDP Views
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 5) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Website'))
WHERE metricNameID = 5

--Total Lead Volume
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 6) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Sales Leads'))
WHERE metricNameID = 6

--Shop Click Drive
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 7) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Website'))
WHERE metricNameID = 7

--Dealership Phone Call Fail Rate
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 17) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 17

--Unanswered
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 18) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 18

--Hold-Time Abandon
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 19) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 19

--IVR/Voicemail Abandon
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 20) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 20

--Ring Transfer Abandon
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 21) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Phone Call'))
WHERE metricNameID = 21

--Internet Lead Close Rate
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 22) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Sales Leads'))
WHERE metricNameID = 22

--% Responded To Within 30
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 23) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Sales Leads'))
WHERE metricNameID = 23

--Average Response Time
UPDATE dbo.BDCMetricMetricName
SET metricTooltip =
	((SELECT metricTooltip FROM #MetricToolTip WHERE metricNameID = 24) + ' ' + (SELECT footnoteDate FROM dbo.BDCMetricFootnote WHERE footnoteName = 'Sales Leads'))
WHERE metricNameID = 24