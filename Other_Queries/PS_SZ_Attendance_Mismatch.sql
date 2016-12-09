SELECT 
PS_RAW.STUDENT_NUMBER,
PS_RAW.DATE_VALUE AS ATT_DATE,
PS_RAW.ATT_CODE AS PS_RAW_CODE,
PS_RAW.DESCRIPTION AS PS_RAW_DESCRIPTION,
PS_RAW.ENROLL_STATUS,
ABBREVIATION AS SCHOOL,
DE.ATTENDANCECODE AS SZ_CODE
FROM (
	SELECT
	S.STUDENT_NUMBER,
	CD.DATE_VALUE AS DATE_VALUE,
	--A.ATT_DATE,
	COALESCE(AC.ATT_CODE,'P') ATT_CODE,
	COALESCE(AC.DESCRIPTION,'Present') 'DESCRIPTION',
	S.ENROLL_STATUS,
	SC.ABBREVIATION
	FROM POWERSCHOOL.POWERSCHOOL_STUDENTS S
			JOIN (
			  SELECT ID STUDENTID, SCHOOLID, GRADE_LEVEL, ENTRYDATE, ENTRYCODE, EXITDATE, EXITCODE FROM POWERSCHOOL.POWERSCHOOL_STUDENTS
			  UNION ALL
			  SELECT STUDENTID, SCHOOLID, GRADE_LEVEL, ENTRYDATE, ENTRYCODE, EXITDATE, EXITCODE FROM POWERSCHOOL.POWERSCHOOL_REENROLLMENTS
			) E ON E.STUDENTID = S.ID
	JOIN POWERSCHOOL.POWERSCHOOL_SCHOOLS SC ON SC.SCHOOL_NUMBER = E.SCHOOLID
	JOIN POWERSCHOOL.POWERSCHOOL_CALENDAR_DAY CD ON CD.SCHOOLID = E.SCHOOLID AND CD.DATE_VALUE BETWEEN E.ENTRYDATE AND E.EXITDATE AND CD.INSESSION=1
	LEFT OUTER JOIN POWERSCHOOL.POWERSCHOOL_ATTENDANCE A ON A.STUDENTID = E.STUDENTID AND A.ATT_DATE = CD.DATE_VALUE
	LEFT JOIN POWERSCHOOL.POWERSCHOOL_ATTENDANCE_CODE AC ON AC.ID = A.ATTENDANCE_CODEID
	WHERE CD.DATE_VALUE BETWEEN '2016-08-08' AND GETDATE()-1
	AND ATT_MODE_CODE ='Att_ModeDaily'
	) PS_RAW
JOIN 
	(SELECT
	S.STUDENT_NUMBER,
	FULLDATE,
	CASE WHEN ATTENDANCECODE = '-----' THEN 'P' ELSE ATTENDANCECODE END AS ATTENDANCECODE,
	CASE WHEN ATTENDANCEDESCRIPTION = '-----' THEN 'Present' ELSE ATTENDANCEDESCRIPTION END AS ATTENDANCEDESCRIPTION
	FROM [dw].[DW_factDailyEnrollment_Day] [DW_factDailyEnrollment_Day]
	  INNER JOIN [dw].[DW_dimStudent] dimS ON ([DW_factDailyEnrollment_Day].[StudentKEY] = DIMS.[StudentKEY])
	  INNER JOIN CUSTOM.CUSTOM_STUDENTBRIDGE SB ON SB.SYSTEMSTUDENTID = DIMS.SYSTEMSTUDENTID
	  INNER JOIN POWERSCHOOL.POWERSCHOOL_STUDENTS S ON S.STUDENT_NUMBER = SB.STUDENT_NUMBER
	  INNER JOIN [dw].[DW_dimAttendanceCode] [DW_dimAttendanceCode] ON ([DW_factDailyEnrollment_Day].[AttendanceCodeKEY] = [DW_dimAttendanceCode].[AttendanceCodeKEY])
	  INNER JOIN [dw].[DW_dimSchoolCalendar] [DW_dimSchoolCalendar] ON ([DW_factDailyEnrollment_Day].[SchoolCalendarKEY] = [DW_dimSchoolCalendar].[SchoolCalendarKEY])
	) DE ON DE.FULLDATE = PS_RAW.DATE_VALUE AND DE.STUDENT_NUMBER = PS_RAW.STUDENT_NUMBER
WHERE PS_RAW.ATT_CODE != DE.ATTENDANCECODE
ORDER BY PS_RAW.STUDENT_NUMBER,PS_RAW.DATE_VALUE
