-----------------------DUPLICATE/OVERLAPPING COURSE ENROLLMENT (PS)
SELECT * FROM (
SELECT 
	S.STUDENT_NUMBER AS STUDENT_NUMBER,
	SCH.ABBREVIATION AS SCHOOL_NAME,
	C.COURSE_NAME AS ERROR_GROUP,
	CAST(CC.DATEENROLLED AS DATE) AS ERROR_DATE,
	LEFT(ABS(CC.TERMID),2) AS YEARID,
	S.GRADE_LEVEL AS GRADE_LEVEL,
	S.LASTFIRST AS LASTFRIST,
	'https://powerschool.kippdc.org/admin/students/allenrollments.html?frn=001'+CAST(S.DCID AS VARCHAR) AS LINK,
	CASE 
		WHEN DATEADD(DAY,-1,CONVERT(DATE,LAG(CC.DATELEFT,1,0) OVER (PARTITION BY STUDENT_NUMBER,C.COURSE_NUMBER ORDER BY CC.DATEENROLLED,CC.DATELEFT),112))
					 >=CONVERT(DATE,CC.DATEENROLLED,112) THEN 'Overlapping course enrollment' 
		ELSE NULL 
	END AS ERROR,
	'PowerSchool' SOURCESYSTEM,
	1 ERRORID
	FROM POWERSCHOOL.POWERSCHOOL_COURSES C
	INNER JOIN POWERSCHOOL.POWERSCHOOL_CC CC ON C.COURSE_NUMBER = CC.COURSE_NUMBER
	JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = CC.STUDENTID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = S.SCHOOLID
	WHERE DATEENROLLED>='2015-07-01'
	) SUB
WHERE ERROR IS NOT NULL

UNION ALL

-----------------------MISSING REFERRAL CATEGORY (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Incident referral category is missing' AS ERROR,
'DeansList' AS SOURCESYSTEM,
2 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term','Expulsion')
AND CATEGORY IS NULL

UNION ALL


-----------------------MISSING INCIDENT TYPE
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Incident missing incident type' AS ERROR,
'DeansList' AS SOURCESYSTEM,
3 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term','Expulsion')
AND INFRACTION IS NULL

UNION ALL


-----------------------MISSING START DATE
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Consequence start date is missing' AS ERROR,
'DeansList' AS SOURCESYSTEM,
4 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term')
AND STARTDATE IS NULL

UNION ALL

-----------------------MISSING END DATE (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END GRADE_LEVEL,
S.LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Consequence end date is missing' AS ERROR,
'DeansList' AS SOURCESYSTEM,
5 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term')
AND ENDDATE IS NULL

UNION ALL


-----------------------MISSING RETURN DATE (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Consequence return date is missing' AS ERROR,
'DeansList' AS SOURCESYSTEM,
6 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term')
AND RETURNDATE IS NULL

UNION ALL


-----------------------CONSEQUENCE MISSING NUM DAYS (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/'+cast(i.incidentid as varchar) AS LINK,
'Consequence is missing number of days' AS ERROR,
'DeansList' AS SOURCESYSTEM,
7 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term')
AND NUMDAYS IS NULL

UNION ALL

-----------------------OSS LONG TERM MARKED AS SHORT TERM

SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'OSS Short Term consequence greater than 4 days' AS ERROR,
'DeansList' AS SOURCESYSTEM,
7 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME = 'OSS Short Term'
AND NUMDAYS>4


UNION ALL

-----------------------OSS SHORT TERM MARKED AS LONG TERM

SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'OSS Long Term consequence Less than 5 days' AS ERROR,
'DeansList' AS SOURCESYSTEM,
8 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME = 'OSS Long Term'
AND NUMDAYS<=4


UNION ALL 


-----------------------MISSING INCIDENT LOCATION (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Incident location is missing' AS ERROR,
'DeansList' AS SOURCESYSTEM,
9 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term','Expulsion')
AND LOCATION IS NULL

UNION ALL 

-----------------------REVERSE PENALTY DATES (DL)
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
PENALTYNAME AS ERROR_GROUP,
CAST(ISSUETS AS DATE) AS ERROR_DATE,
CAL.YEARID AS YEARID,
CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
END AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'End date is before start date ' AS ERROR,
'DeansList' AS SOURCESYSTEM,
10 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
JOIN (SELECT DISTINCT
		CASE 
			WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
			WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
			ELSE NULL 
		END YEARID
		,DATE_VALUE
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		) CAL ON CAL.DATE_VALUE = I.CREATETS
WHERE PENALTYNAME IN ('OSS Short Term','OSS Long Term')
AND ENDDATE<STARTDATE


UNION ALL


-----------------------REVERSE SCHOOL ENROLLMENTS (PS)
SELECT
SUB.STUDENT_NUMBER AS STUDENT_NUMBER,
SUB.ABBREVIATION AS SCHOOL_NAME,
--SUB.[ENTRY / EXIT],
'Enrollment' AS ERROR_GROUP,
CAST(SUB.ENTRYDATE AS DATE) AS ERRORDATE,
(CAST(RIGHT(CAST(DATEPART(YY,SUB.ENTRYDATE) AS VARCHAR),2) AS INT)+10) AS YEARID,
SUB.GRADE_LEVEL AS GRADE_LEVEL,
SUB.LASTFIRST AS LASTFIRST,
'https://powerschool.kippdc.org/admin/students/transferinfo.html?frn=001' + CAST(SUB.DCID AS VARCHAR) AS LINK,
SUB.ERROR AS ERROR,
'PowerSchool' AS SOURCESYSTEM,
11 ERRORID
FROM
(SELECT
	STUDENT_NUMBER,
	SCH.ABBREVIATION,
	E.GRADE_LEVEL,
	S.LASTFIRST,
	S.DCID,
	E.ENTRYDATE,
	E.EXITDATE,
	CAST(CONVERT(DATE,E.ENTRYDATE,112) AS VARCHAR) +' / '+CAST(CONVERT(DATE,E.EXITDATE,112) AS VARCHAR) 'Entry / Exit',
	CASE
		WHEN CONVERT(DATE,E.EXITDATE,112)<CONVERT(DATE,E.ENTRYDATE,112) THEN 'Enrollment exit date is before entry date (reverse enrollment)'
	END AS 'Error'
	FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
	JOIN (
	  SELECT S.ID STUDENTID, S.SCHOOLID, S.ENTRYDATE, S.EXITDATE, S.ENTRYCODE, S.EXITCODE, S.GRADE_LEVEL FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
	  UNION
	  SELECT R.STUDENTID, R.SCHOOLID, R.ENTRYDATE, R.EXITDATE , R.ENTRYCODE, R.EXITCODE, R.GRADE_LEVEL FROM [POWERSCHOOL].[POWERSCHOOL_REENROLLMENTS] R
	) E ON E.STUDENTID = S.ID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = E.SCHOOLID
	) SUB
WHERE ERROR IS NOT NULL

UNION ALL


-----------------------OVERLAPPING SCHOOL ENROLLMENTS (PS)
SELECT
SUB.STUDENT_NUMBER AS STUDENT_NUMBER,
SUB.ABBREVIATION AS SCHOOL_NAME,
--SUB.[ENTRY / EXIT],
'Enrollment' AS ERROR_GROUP,
CAST(SUB.ENTRYDATE AS DATE) AS ERRORDATE,
(CAST(RIGHT(CAST(DATEPART(YY,SUB.ENTRYDATE) AS VARCHAR),2) AS INT)+10) AS YEARID,
SUB.GRADE_LEVEL AS GRADE_LEVEL,
SUB.LASTFIRST AS LASTFIRST,
'https://powerschool.kippdc.org/admin/students/transferinfo.html?frn=001' + CAST(SUB.DCID AS VARCHAR) AS LINK,
SUB.ERROR AS ERROR,
'PowerSchool' AS SOURCESYSTEM,
12 ERRORID
FROM
(SELECT
	STUDENT_NUMBER,
	SCH.ABBREVIATION,
	E.GRADE_LEVEL,
	S.LASTFIRST,
	S.DCID,
	E.ENTRYDATE,
	E.EXITDATE,
	CAST(CONVERT(DATE,E.ENTRYDATE,112) AS VARCHAR) +' / '+CAST(CONVERT(DATE,E.EXITDATE,112) AS VARCHAR) 'Entry / Exit',
	CASE 
		  WHEN CONVERT(DATE,LAG(E.EXITDATE,1,0) OVER(PARTITION BY STUDENT_NUMBER ORDER BY STUDENT_NUMBER ,E.ENTRYDATE,E.EXITDATE),112)>CONVERT(DATE,E.ENTRYDATE,112) THEN 'Overlapping school enrollments'
		  ELSE NULL 
	 END ERROR
	FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
	JOIN (
	  SELECT S.ID STUDENTID, S.SCHOOLID, S.ENTRYDATE, S.EXITDATE, S.ENTRYCODE, S.EXITCODE, S.GRADE_LEVEL FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
	  UNION
	  SELECT R.STUDENTID, R.SCHOOLID, R.ENTRYDATE, R.EXITDATE , R.ENTRYCODE, R.EXITCODE, R.GRADE_LEVEL FROM [POWERSCHOOL].[POWERSCHOOL_REENROLLMENTS] R
	) E ON E.STUDENTID = S.ID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = E.SCHOOLID
	) SUB
WHERE ERROR IS NOT NULL

UNION ALL


-----------------------GAPS IN HOMEROOM ENROLLMENT (PS) -- 15-16 school year only

SELECT
 SUB.STUDENT_NUMBER AS STUDENT_NUMBER
,SUB.ABBREVIATION AS SCHOOL_NAME
,'Homeroom' ERROR_GROUP
,MIN(CAST(SUB.DATE_VALUE AS DATE)) AS ERROR_DATE
,SUB.YEARID AS YEARID
,SUB.GRADE_LEVEL AS GRADE_LEVEL
,SUB.LASTFIRST AS LASTFIRST
,'https://powerschool.kippdc.org/admin/students/allenrollments.html?frn=001'+CAST(SUB.DCID AS VARCHAR) AS LINK
,'Not enrolled in section on in session days' AS ERROR
,'PowerSchool' AS SOURCESYSTEM,
13 ERRORID
FROM
	(
	SELECT 
	 CD.DATE_VALUE 
	,E.STUDENTID
	,E.SCHOOLID ENROLLED_SCHOOL
	,SEC.SECTION_NUMBER
	,S.STUDENT_NUMBER
	,SCH.ABBREVIATION
	,E.GRADE_LEVEL
	,S.LASTFIRST
	,S.DCID
	,CASE  --CREATE YEARID WITH THE LAST 2 DIGITS OF THE YEAR +10 IF BETWEEN AUG AND DEC OR +9 IF BETWEEN JAN AND JUL OF FOLLOWING YEAR
		WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
		WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
	END YEARID
	FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
	JOIN  
		(
		SELECT 
		S.ID STUDENTID
		,S.SCHOOLID
		,S.ENTRYDATE
		,S.EXITDATE
		,S.GRADE_LEVEL
		FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
		UNION
		SELECT 
		 R.STUDENTID
		,R.SCHOOLID
		,R.ENTRYDATE
		,R.EXITDATE
		,R.GRADE_LEVEL
		FROM [POWERSCHOOL].[POWERSCHOOL_REENROLLMENTS] R
		) E ON DATE_VALUE BETWEEN E.ENTRYDATE AND E.EXITDATE-1 AND E.SCHOOLID = CD.SCHOOLID
	JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = E.STUDENTID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = E.SCHOOLID
	LEFT JOIN 
		(	
		SELECT
		CD.DATE_VALUE DATE
		,CC.SECTION_NUMBER SECTION_NUMBER
		,CC.SCHOOLID SCHOOLID
		,CC.STUDENTID STUDENTID
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		JOIN POWERSCHOOL.POWERSCHOOL_CC CC
		JOIN POWERSCHOOL.POWERSCHOOL_COURSES C ON C.COURSE_NUMBER = CC.COURSE_NUMBER
		ON CD.DATE_VALUE BETWEEN CC.DATEENROLLED AND CC.DATELEFT AND CD.SCHOOLID = CC.SCHOOLID
		WHERE C.COURSE_NAME = 'Homeroom'
		) SEC ON SEC.DATE = CD.DATE_VALUE AND SEC.SCHOOLID = CD.SCHOOLID AND SEC.STUDENTID = E.STUDENTID
		WHERE CD.INSESSION = 1
		AND CD.DATE_VALUE < GETDATE()--BETWEEN '2015-07-10' AND GETDATE()
		AND E.SCHOOLID != 1100  -- KCP does not have homerooms
)  SUB

WHERE SECTION_NUMBER IS NULL
AND SUB.YEARID>=25
AND SUB.STUDENTID NOT IN (SELECT SP.STUDENTID
						  FROM POWERSCHOOL.POWERSCHOOL_SPENROLLMENTS SP
						  JOIN POWERSCHOOL.POWERSCHOOL_GEN GEN ON GEN.ID = SP.PROGRAMID AND GEN.CAT='specprog'
						  WHERE GEN.NAME = 'Learning Center')
GROUP BY  SUB.STUDENT_NUMBER
         ,SUB.DCID
		 ,SUB.ABBREVIATION
		 ,SUB.YEARID
		 ,SUB.GRADE_LEVEL
		 ,SUB.LASTFIRST


UNION ALL

-----------------------GAPS IN ATTENDANCE ENROLLMENT (PS) -- 15-16 school year only

SELECT
 SUB.STUDENT_NUMBER AS STUDENT_NUMBER
,SUB.ABBREVIATION AS SCHOOL_NAME
,'Attendance' ERROR_GROUP
,MIN(CAST(SUB.DATE_VALUE AS DATE)) AS ERROR_DATE
,SUB.YEARID AS YEARID
,SUB.GRADE_LEVEL AS GRADE_LEVEL
,SUB.LASTFIRST AS LASTFIRST
,'https://powerschool.kippdc.org/admin/students/allenrollments.html?frn=001'+CAST(SUB.DCID AS VARCHAR) AS LINK
,'Not enrolled in section on in session days' AS ERROR
,'PowerSchool' AS SOURCESYSTEM
,14 ERRORID
FROM
	(
	SELECT 
	 CD.DATE_VALUE 
	,E.STUDENTID
	,E.SCHOOLID ENROLLED_SCHOOL
	,SEC.SECTION_NUMBER
	,S.STUDENT_NUMBER
	,SCH.ABBREVIATION
	,E.GRADE_LEVEL
	,S.LASTFIRST
	,S.DCID
	,CASE  --CREATE YEARID WITH THE LAST 2 DIGITS OF THE YEAR +10 IF BETWEEN AUG AND DEC OR +9 IF BETWEEN JAN AND JUL OF FOLLOWING YEAR
		WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
		WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
	END YEARID
	FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
	JOIN  
		(
		SELECT 
		S.ID STUDENTID
		,S.SCHOOLID
		,S.ENTRYDATE
		,S.EXITDATE
		,S.GRADE_LEVEL
		FROM [POWERSCHOOL].[POWERSCHOOL_STUDENTS] S
		UNION
		SELECT 
		 R.STUDENTID
		,R.SCHOOLID
		,R.ENTRYDATE
		,R.EXITDATE
		,R.GRADE_LEVEL
		FROM [POWERSCHOOL].[POWERSCHOOL_REENROLLMENTS] R
		) E ON DATE_VALUE BETWEEN E.ENTRYDATE AND E.EXITDATE-1 AND E.SCHOOLID = CD.SCHOOLID
	JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = E.STUDENTID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = E.SCHOOLID
	LEFT JOIN 
		(	
		SELECT
		CD.DATE_VALUE DATE
		,CC.SECTION_NUMBER SECTION_NUMBER
		,CC.SCHOOLID SCHOOLID
		,CC.STUDENTID STUDENTID
		FROM POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD
		JOIN POWERSCHOOL.POWERSCHOOL_CC CC
		JOIN POWERSCHOOL.POWERSCHOOL_COURSES C ON C.COURSE_NUMBER = CC.COURSE_NUMBER
		ON CD.DATE_VALUE BETWEEN CC.DATEENROLLED AND CC.DATELEFT AND CD.SCHOOLID = CC.SCHOOLID
		WHERE C.COURSE_NAME = 'Attendance'
		) SEC ON SEC.DATE = CD.DATE_VALUE AND SEC.SCHOOLID = CD.SCHOOLID AND SEC.STUDENTID = E.STUDENTID
		WHERE CD.INSESSION = 1
		AND CD.DATE_VALUE < GETDATE()--BETWEEN '2015-07-10' AND GETDATE()
		AND E.SCHOOLID != 1100  -- KCP does not have homerooms
)  SUB

WHERE SECTION_NUMBER IS NULL
AND SUB.YEARID>=25
AND SUB.STUDENTID NOT IN (SELECT SP.STUDENTID
						  FROM POWERSCHOOL.POWERSCHOOL_SPENROLLMENTS SP
						  JOIN POWERSCHOOL.POWERSCHOOL_GEN GEN ON GEN.ID = SP.PROGRAMID AND GEN.CAT='specprog'
						  WHERE GEN.NAME = 'Learning Center')
GROUP BY  SUB.STUDENT_NUMBER
         ,SUB.DCID
		 ,SUB.ABBREVIATION
		 ,SUB.YEARID
		 ,SUB.GRADE_LEVEL
		 ,SUB.LASTFIRST


UNION ALL

-----------------------CONSEQUENCE START DATE NOT IN SESSION DAY

SELECT 
 I.STUDENTSCHOOLID AS STUDENT_NUMBER
,SCH.ABBREVIATION AS SCHOOL_NAME
,P.PENALTYNAME AS ERROR_GROUP
,CAST(P.STARTDATE AS DATE) AS ERROR_DATE
,CASE 
	WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
	WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
 END AS YEARID
,CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
 END AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST
,'https://kippdc.deanslistsoftware.com/incidents/'+CAST(I.INCIDENTID AS VARCHAR) AS LINK
,'Consequence start date is not an in session day' AS ERROR
,'DeansList' AS SOURCESYSTEM
,15 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.DATE_VALUE = P.STARTDATE AND CD.SCHOOLID = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
WHERE CD.INSESSION=0
AND P.PENALTYNAME IN ('OSS Short Term','OSS Long Term')

UNION ALL

-----------------------CONSEQUENCE END DATE NOT IN SESSION DAY

SELECT 
 I.STUDENTSCHOOLID AS STUDENT_NUMBER
,SCH.ABBREVIATION AS SCHOOL_NAME
,P.PENALTYNAME AS ERROR_GROUP
,CAST(P.ENDDATE AS DATE) AS ERROR_DATE
,CASE 
	WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
	WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
 END AS YEARID
,CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
 END AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST
,'https://kippdc.deanslistsoftware.com/incidents/'+CAST(I.INCIDENTID AS VARCHAR) AS LINK
,'Consequence end date is not an in session day' AS ERROR
,'DeansList' AS SOURCESYSTEM
,16 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.DATE_VALUE = P.ENDDATE AND CD.SCHOOLID = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
WHERE CD.INSESSION=0
AND P.PENALTYNAME IN ('OSS Short Term','OSS Long Term')

UNION ALL

-----------------------CONSEQUENCE RETURN DATE NOT IN SESSION DAY

SELECT 
 I.STUDENTSCHOOLID AS STUDENT_NUMBER
,SCH.ABBREVIATION AS SCHOOL_NAME
,P.PENALTYNAME AS ERROR_GROUP
,CAST(I.RETURNDATE AS DATE) AS ERROR_DATE
,CASE 
	WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
	WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
 END AS YEARID
,CASE
	WHEN GRADELEVELSHORT = 'PK3' THEN -2
	WHEN GRADELEVELSHORT = 'PK4' THEN -1
	WHEN GRADELEVELSHORT = 'K' THEN 0
	ELSE CAST(LEFT(I.GRADELEVELSHORT,1) AS INT)
 END AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST
,'https://kippdc.deanslistsoftware.com/incidents/'+CAST(I.INCIDENTID AS VARCHAR) AS LINK
,'Consequence return date is not an in session day' AS ERROR
,'DeansList' AS SOURCESYSTEM
,17 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID AND I.INCIDENTID!=-1
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.DATE_VALUE = I.RETURNDATE AND CD.SCHOOLID = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
WHERE CD.INSESSION=0
AND P.PENALTYNAME IN ('OSS Short Term','OSS Long Term')


UNION ALL


-----------------------OVERLAPPING SECTION ENROLLMENT
SELECT 
 S.STUDENT_NUMBER AS STUDENT_NUMBER
,SCH.ABBREVIATION AS SCHOOL_NAME
,C.COURSE_NAME AS ERROR_GROUP
,CAST(CC.DATEENROLLED AS DATE) AS ERROR_DATE
,LEFT(ABS(CC.TERMID),2) AS YEARID
,S.GRADE_LEVEL AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST
,'https://powerschool.kippdc.org/admin/students/allenrollments.html?frn=001'+CAST(S.DCID AS VARCHAR) AS LINK
,'Overlapping section enrollment' AS ERROR
,'PowerSchool' AS SOURCESYSTEM
,18 ERRORID
FROM POWERSCHOOL.POWERSCHOOL_CC CC
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = CC.STUDENTID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = CC.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_COURSES C ON C.COURSE_NUMBER = CC.COURSE_NUMBER
WHERE CC.DATEENROLLED>CC.DATELEFT

UNION ALL

-----------------------MISSING OSS ATTENDANCE RECORD
SELECT 
I.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
'Attendance' AS ERROR_GROUP,
CAST(CD.DATE_VALUE AS DATE) AS ERROR_DATE,
CASE 
	WHEN DATEPART(MM,CD.DATE_VALUE)>=7 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+10
	WHEN DATEPART(MM,CD.DATE_VALUE)<=6 THEN RIGHT(DATEPART(YY,CD.DATE_VALUE),2)+9
	ELSE NULL 
END AS YEARID,
S.GRADE_LEVEL AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
'https://kippdc.deanslistsoftware.com/incidents/' + CAST(I.INCIDENTID AS VARCHAR) AS LINK,
'Missing OSS attendance record' AS ERROR,
'DeansList' AS SOURCESYSTEM,
19 ERRORID
FROM CUSTOM_DLINCIDENTS_RAW I
LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = I.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.DATE_VALUE BETWEEN P.STARTDATE AND P.ENDDATE AND CD.SCHOOLID = SB.PSSCHOOLID
JOIN CUSTOM_DLATTENDANCE_RAW A ON A.BEHAVIORDATE = CD.DATE_VALUE AND I.STUDENTSCHOOLID = A.STUDENTSCHOOLID AND BEHAVIORCATEGORY = 'Daily Attendance'
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = I.STUDENTSCHOOLID
WHERE P.PENALTYNAME LIKE 'OSS%'
AND A.BEHAVIOR != '"O" Out of School Suspension'
AND CD.INSESSION = 1  --DL has school calendar, but days retroactively marked out of session still have records that come through so must be excluded here as well
UNION ALL 

-----------------------OSS ATTENDANCE RECORD OUTSIDE A CORRESPONDING SUSPENSION

SELECT 
A.STUDENTSCHOOLID AS STUDENT_NUMBER,
SCH.ABBREVIATION AS SCHOOL_NAME,
'Attendance' AS ERROR_GROUP,
CAST(A.BEHAVIORDATE AS DATE) AS ERROR_DATE,
CASE 
	WHEN DATEPART(MM,A.BEHAVIORDATE)>=7 THEN RIGHT(DATEPART(YY,A.BEHAVIORDATE),2)+10
	WHEN DATEPART(MM,A.BEHAVIORDATE)<=6 THEN RIGHT(DATEPART(YY,A.BEHAVIORDATE),2)+9
	ELSE NULL 
END AS YEARID,
S.GRADE_LEVEL AS GRADE_LEVEL,
S.LASTFIRST AS LASTFIRST,
NULL AS LINK,
'OSS attendance record outside a suspension' AS ERROR,
'DeansList' AS SOURCESYSTEM,
20 ERRORID
FROM CUSTOM_DLATTENDANCE_RAW A
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = A.STUDENTSCHOOLID
JOIN CUSTOM_DLSCHOOLBRIDGE SB ON SB.DLSCHOOLID = A.DLSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SB.PSSCHOOLID
LEFT JOIN 
(SELECT 
  I.STUDENTSCHOOLID
 ,P.STARTDATE
 ,P.ENDDATE
 ,P.PENALTYNAME
 FROM CUSTOM_DLINCIDENTS_RAW I
 LEFT JOIN CUSTOM_DLPENALTIES_RAW P ON P.INCIDENTID = I.INCIDENTID
 WHERE P.PENALTYNAME LIKE 'OSS%'
) OSS ON OSS.STUDENTSCHOOLID = A.STUDENTSCHOOLID AND OSS.PENALTYNAME LIKE 'OSS%' AND (A.BEHAVIORDATE BETWEEN OSS.STARTDATE AND OSS.ENDDATE)
WHERE A.BEHAVIOR = '"O" Out of School Suspension'
AND OSS.STUDENTSCHOOLID IS NULL


UNION ALL

-----------------------MULTIPLE ATTENDANCE RECORDS ON A SINGLE DAY

SELECT 
 ATT.STUDENTSCHOOLID
,SCH.ABBREVIATION
,'Attendance' AS ERROR_GROUP
,CAST(ATT.BEHAVIORDATE AS DATE) AS ERROR_DATE
,CASE 
	WHEN DATEPART(MM,ATT.BEHAVIORDATE)>=7 THEN RIGHT(DATEPART(YY,ATT.BEHAVIORDATE),2)+10
	WHEN DATEPART(MM,ATT.BEHAVIORDATE)<=6 THEN RIGHT(DATEPART(YY,ATT.BEHAVIORDATE),2)+9
	ELSE NULL 
END AS YEARID
,S.GRADE_LEVEL AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST--+' ('+CSD.HOMEROOM+')'
,'https://kippdc.deanslistsoftware.com/master-attendance/master-attendance.php' AS LINK
,'Multiple attendance records on a single day' AS ERROR
,'DeansList' AS SOURCESYSTEM
,21 ERRORID
FROM CUSTOM_DLATTENDANCE_RAW ATT
JOIN CUSTOM_DLSCHOOLBRIDGE SCHB ON SCHB.DLSCHOOLID = ATT.DLSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SCH ON SCH.SCHOOL_NUMBER = SCHB.PSSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = ATT.STUDENTSCHOOLID
JOIN CUSTOM.CUSTOM_STUDENTBRIDGE SB ON SB.STUDENT_NUMBER = S.STUDENT_NUMBER
JOIN CUSTOM.CUSTOM_STUDENTS_DAILY CSD ON CSD.SYSTEMSTUDENTID = SB.SYSTEMSTUDENTID AND CSD.FULLDATE = ATT.BEHAVIORDATE
WHERE ATT.BEHAVIORCATEGORY = 'Daily Attendance'
GROUP BY STUDENTSCHOOLID,SCH.ABBREVIATION,S.GRADE_LEVEL,S.LASTFIRST,BEHAVIORDATE,CSD.HOMEROOM
HAVING COUNT(*)>1

UNION ALL

-----------------------REVERSE COURSE ENROLLMENT

 SELECT 
 S.STUDENT_NUMBER AS STUDENT_NUMBER
,SC.ABBREVIATION AS SCHOOL_NAME
,C.COURSE_NAME AS ERROR_GROUP
,CC.DATEENROLLED AS ERROR_DATE
,T.YEARID AS YEARID
,NULL AS GRADE_LEVEL
,S.LASTFIRST AS LASTFIRST
,'https://powerschool.kippdc.org/admin/students/allenrollments.html?frn=001'+CAST(S.DCID AS VARCHAR) AS LINK
,'Course enrollment exit date is before entry date (reverse enrollment)' AS ERROR
,'Powerschool' AS SOURCESYSTEM
,22 ERRORID
FROM POWERSCHOOL.POWERSCHOOL_CC CC
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = CC.STUDENTID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SC ON SC.SCHOOL_NUMBER = S.SCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_COURSES C ON C.COURSE_NUMBER = CC.COURSE_NUMBER
JOIN POWERSCHOOL.POWERSCHOOL_TERMS T ON T.ID = CC.TERMID AND T.SCHOOLID = SC.SCHOOL_NUMBER
WHERE DATEENROLLED>DATELEFT
and yearid=25

UNION

-----------------------MISMATCH BETWEEN DL AND PS ATTENDANCE CODES

SELECT
DL_ATT.STUDENTSCHOOLID AS STUDENT_NUMBER,
--DL_ATT.SCHOOLNAME AS SCHOOL_NAME,
SC.ABBREVIATION,
'DL: '+DL_ATT.BEHAVIOR+' / '+'PS: '+PS_ATT.[DESCRIPTION] AS ERROR_GROUP, --mismatched attendance values in DL and PS
CAST(DL_ATT.BEHAVIORDATE AS DATE) AS ERROR_DATE,
PS_ATT.YEARID AS YEARID,
S.GRADE_LEVEL ,
S.LASTFIRST,
'https://powerschool.kippdc.org/admin/attendance/view/daily.html?frn=001' + CAST(S.DCID AS VARCHAR) AS LINK,
'Mismatch between Deanslist and Powerschool attendance records' AS ERROR,
'PowerSchool' AS SOURCESYSTEM,
32 AS ERRORID
FROM CUSTOM.CUSTOM_DLATTENDANCE_RAW DL_ATT
JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = DL_ATT.STUDENTSCHOOLID
JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SC ON SC.SCHOOL_NUMBER = S.SCHOOLID
JOIN (SELECT
		S.STUDENT_NUMBER STUDENT_NUMBER,
		CD.DATE_VALUE,
		E.ENTRYDATE,
		E.EXITDATE,
		A.YEARID,
		AC.ATT_CODE,
		CASE
			WHEN CD.DATE_VALUE>=E.ENTRYDATE AND CD.DATE_VALUE<E.EXITDATE THEN 1
			ELSE 0
		END ENROLL_STATUS,
		COALESCE(AC.DESCRIPTION,'Present') "DESCRIPTION"
		FROM POWERSCHOOL.POWERSCHOOL_SCHOOLS SC
		JOIN (
		  SELECT ID STUDENTID, SCHOOLID, GRADE_LEVEL, ENTRYDATE, ENTRYCODE, EXITDATE, EXITCODE FROM POWERSCHOOL.POWERSCHOOL_STUDENTS
		  UNION ALL
		  SELECT STUDENTID, SCHOOLID, GRADE_LEVEL, ENTRYDATE, ENTRYCODE, EXITDATE, EXITCODE FROM POWERSCHOOL.POWERSCHOOL_REENROLLMENTS
		) E ON E.SCHOOLID = SC.SCHOOL_NUMBER AND SC.SCHOOL_NUMBER!=2001
		JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.ID = E.STUDENTID
		JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.SCHOOLID = E.SCHOOLID AND CD.DATE_VALUE BETWEEN E.ENTRYDATE AND E.EXITDATE-1 AND CD.INSESSION = 1
		LEFT OUTER JOIN POWERSCHOOL.POWERSCHOOL_ATTENDANCE A ON A.STUDENTID = E.STUDENTID AND A.ATT_DATE = CD.DATE_VALUE AND ATT_MODE_CODE = 'ATT_MODEDAILY'
		LEFT JOIN POWERSCHOOL.POWERSCHOOL_ATTENDANCE_CODE AC ON AC.ID = A.ATTENDANCE_CODEID
		--WHERE CD.DATE_VALUE >= '2015-08-10'
		) PS_ATT ON PS_ATT.STUDENT_NUMBER = DL_ATT.STUDENTSCHOOLID AND PS_ATT.DATE_VALUE = DL_ATT.BEHAVIORDATE
WHERE BEHAVIORCATEGORY = 'Daily Attendance'
--AND DL_ATT.BEHAVIOR NOT LIKE '%'+PS_ATT.[DESCRIPTION]
AND PS_ATT.ATT_CODE != DL_ATT.ATTENDANCECODE
AND PS_ATT.ENROLL_STATUS = 1
AND S.HOME_ROOM NOT LIKE 'LC%'
