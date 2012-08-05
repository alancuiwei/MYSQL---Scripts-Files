-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema futuretest
--

CREATE DATABASE IF NOT EXISTS futuretest;
USE futuretest;

--
-- Definition of procedure `computecontractdate_p`
--

DROP PROCEDURE IF EXISTS `computecontractdate_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `computecontractdate_p`(
IN in_contractid VARCHAR(10), 
OUT out_lasttradedate DATE,
OUT out_startdeliverdate DATE,
OUT out_lastdeliverdate DATE
)
BEGIN

DECLARE v_commodityid VARCHAR(4);
DECLARE v_datenum INT DEFAULT 4;
DECLARE v_delivermonth1stday DATE;
DECLARE v_lasttradeday VARCHAR(4);
DECLARE v_startdeliverday VARCHAR(4);
DECLARE v_lastdeliverday VARCHAR(4);
DECLARE v_delivercheckday VARCHAR(4);
DECLARE v_checkid INT;
DECLARE v_checkdate DATE;
DECLARE v_computetype INT;
DECLARE v_exchangeid VARCHAR(4);
DECLARE v_delivermargin VARCHAR(4);
DECLARE v_year VARCHAR(4) DEFAULT '2011';
DECLARE v_year1 CHAR(1) DEFAULT '1';
DECLARE v_month VARCHAR(2) DEFAULT '01';
DECLARE v_day VARCHAR(2) DEFAULT '01';
DECLARE done INT DEFAULT 0;
DECLARE cur_delivercheckday CURSOR FOR SELECT delivercheckday, checkid, delivermargin FROM commoditydelivermargin_t
                    WHERE commodityid=v_commodityid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;


IF (SELECT in_contractid REGEXP BINARY '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
  SET v_datenum=3;
ELSE
  SET v_datenum=4;
END IF;
SET v_commodityid=LEFT(in_contractid, LENGTH(in_contractid)-v_datenum );

SET v_year1=MID(in_contractid, LENGTH(in_contractid)-2,1);
SET v_month=RIGHT(in_contractid, 2);
IF (v_year1<RIGHT(YEAR(CURDATE()), 1)) THEN
  SET v_year=CONCAT(LEFT(YEAR(CURDATE())+1, 3), v_year1);
ELSE
  SET v_year=CONCAT(LEFT(YEAR(CURDATE()), 3), v_year1);
END IF;


SET v_delivermonth1stday=CONCAT(v_year, '-', v_month, '-', '01');


SELECT exchangeid, lasttradeday, startdeliverday, lastdeliverday 
       INTO v_exchangeid, v_lasttradeday, v_startdeliverday, v_lastdeliverday FROM commodity_t
       WHERE commodityid=v_commodityid;
       

CALL computedate_p(v_delivermonth1stday,v_lasttradeday, out_lasttradedate);


SET v_computetype=MID(v_startdeliverday, 2, 1);

IF v_computetype=4 OR v_computetype=5 THEN
  CALL computedate_p(out_lasttradedate, v_startdeliverday, out_startdeliverdate);
ELSE
  CALL computedate_p(v_delivermonth1stday, v_startdeliverday, out_startdeliverdate);
END IF;


SET v_computetype=MID(v_lastdeliverday, 2, 1);

IF v_computetype=4 OR v_computetype=5 THEN
  CALL computedate_p(out_lasttradedate, v_lastdeliverday, out_lastdeliverdate);
ELSE
  CALL computedate_p(v_delivermonth1stday, v_lastdeliverday, out_lastdeliverdate);
END IF;


OPEN cur_delivercheckday;
FETCH cur_delivercheckday INTO v_delivercheckday, v_checkid, v_delivermargin;
REPEAT
  IF NOT done THEN
    SET v_computetype=MID(v_delivercheckday, 2, 1);
    
    IF v_computetype=5 OR v_computetype=4 THEN
      CALL computedate_p(out_lasttradedate, v_delivercheckday, v_checkdate);
    ELSE
      CALL computedate_p(v_delivermonth1stday, v_delivercheckday, v_checkdate);
    END IF;
    
    IF (SELECT contractid FROM contractdelivermargin_t WHERE contractid=in_contractid 
                  AND checkid=v_checkid) IS NULL THEN
      INSERT contractdelivermargin_t(contractid, checkid, actualdelivercheckdate, delivermargin)
             VALUE(in_contractid, v_checkid, v_checkdate, v_delivermargin);
             
    ELSE
      UPDATE contractdelivermargin_t SET
             actualdelivercheckdate=v_checkdate,
             delivermargin=v_delivermargin
             WHERE contractid=in_contractid AND checkid=v_checkid;
    END IF;
  END IF;

  FETCH NEXT FROM cur_delivercheckday INTO v_delivercheckday, v_checkid, v_delivermargin;
  
UNTIL done END REPEAT;


CLOSE cur_delivercheckday;

END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `computedate_p`
--

DROP PROCEDURE IF EXISTS `computedate_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `computedate_p`(
IN in_basedate DATE,
IN in_rules VARCHAR(6),
OUT out_computedate DATE
)
label1:BEGIN

DECLARE v_offsetdays INT;
DECLARE v_offsetmonths INT;
DECLARE v_offsetweeks INT;
DECLARE v_computetype INT;


IF (in_basedate IS NULL) OR (in_rules IS NULL) THEN
  LEAVE label1;
END IF;


SET v_offsetmonths=MID(in_rules, 1, 1);
SET v_computetype=MID(in_rules, 2, 1);
SET v_offsetdays=MID(in_rules, 3, 2);


CASE v_computetype
  
  WHEN 0 THEN
    SET out_computedate=(SELECT everydate FROM exchangecalendar_t WHERE
                           orderid=(SELECT orderid FROM exchangecalendar_t WHERE
                           everydate=LAST_DAY(DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH)))-v_offsetdays+1
                           AND isworkday=true);
                           
  WHEN 1 THEN
    SET out_computedate=(SELECT everydate FROM exchangecalendar_t WHERE
                           orderid=(SELECT MAX(orderid) FROM exchangecalendar_t WHERE
                           everydate<DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH))+v_offsetdays
                           AND isworkday=true);
                           
  WHEN 2 THEN
    SET v_offsetweeks=MID(in_rules, 3, 1);
    SET v_offsetdays=MID(in_rules, 4, 1);
    SET @u_offsetweeks=v_offsetweeks-1;
    PREPARE preoffsetweeks FROM 'SELECT everydate FROM exchangecalendar_t WHERE
                            (everydate BETWEEN DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH)
                             AND LAST_DAY(DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH)))
                             AND isworkday=true AND weekday=v_offsetdays ORDER BY everydate ASC LIMIT ?,1';
    EXECUTE preoffsetweeks USING @u_offsetweeks;
    DEALLOCATE PREPARE preoffsetweeks;
   

  WHEN 3 THEN
    SET v_offsetweeks=MID(in_rules, 3, 1)-1;
    SET v_offsetdays=MID(in_rules, 4, 1)-1;
    SET @u_offsetweeks=v_offsetweeks;
    SET @u_offsetdates = in_basedate;
    SET @u_offsetmonths = v_offsetmonths;
    SET @u_offsetdays = v_offsetdays;
    PREPARE preoffsetweeks FROM 'SELECT everydate FROM exchangecalendar_t WHERE
                            (everydate BETWEEN DATE_SUB(@u_offsetdates, INTERVAL @u_offsetmonths MONTH)
                             AND LAST_DAY(DATE_SUB(@u_offsetdates, INTERVAL @u_offsetmonths MONTH)))
                             AND isworkday=true AND weekday=@u_offsetdays ORDER BY everydate ASC LIMIT ?,1';
    EXECUTE preoffsetweeks USING @u_offsetweeks;
    DEALLOCATE PREPARE preoffsetweeks;
  
  WHEN 4 THEN
    SET out_computedate=(SELECT everydate FROM exchangecalendar_t WHERE
                           orderid=(SELECT orderid FROM exchangecalendar_t WHERE
                           everydate=DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH))-v_offsetdays+1
                           AND isworkday=true);
    
  WHEN 5 THEN
    SET out_computedate=(SELECT everydate FROM exchangecalendar_t WHERE
                           orderid=(SELECT MAX(orderid) FROM exchangecalendar_t WHERE
                           everydate=DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH))+v_offsetdays
                           AND isworkday=true);
  
  WHEN 9 THEN
    SET out_computedate=(SELECT everydate FROM exchangecalendar_t WHERE
                           orderid=(SELECT MAX(orderid) FROM exchangecalendar_t WHERE 
                           everydate<DATE_ADD(DATE_SUB(in_basedate, INTERVAL v_offsetmonths MONTH), INTERVAL (v_offsetdays-1) DAY))+1
                           AND isworkday=true);
END CASE;

END label1 $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `computemarketdaydata_p`
--

DROP PROCEDURE IF EXISTS `computemarketdaydata_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `computemarketdaydata_p`()
top:BEGIN
DECLARE v_contractid VARCHAR(10);
DECLARE v_currentprice DOUBLE;
DECLARE v_highprice DOUBLE;
DECLARE v_lowprice DOUBLE;
DECLARE v_openprice DOUBLE;
DECLARE v_closeprice DOUBLE;
DECLARE v_volume DOUBLE;
DECLARE v_openinterest DOUBLE;
DECLARE v_settlementprice DOUBLE;
DECLARE v_errorid INT;
DECLARE done INT DEFAULT 0;
DECLARE cur_contract CURSOR FOR SELECT contractid FROM validcontracts_t;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


IF IFNULL((SELECT isworkday FROM exchangecalendar_t WHERE everydate=CURRENT_DATE),0)<>1 THEN
  LEAVE top;
END IF;


DROP TABLE IF EXISTS todayvalidmarketdata_tmp_t;
CREATE TEMPORARY TABLE  todayvalidmarketdata_tmp_t select * from markettodaydata_t
WHERE closeprice between 1 and 1000000 and settlementprice between 1 and 1000000;



OPEN cur_contract;
FETCH cur_contract INTO v_contractid;
WHILE NOT done DO
  
  SET v_volume=NULL;
  SET v_errorid=0;
  SELECT currentprice, openprice, highprice, lowprice, closeprice, volume, openinterest, settlementprice
       INTO  v_currentprice, v_openprice, v_highprice, v_lowprice, v_closeprice, v_volume, v_openinterest, v_settlementprice
       FROM todayvalidmarketdata_tmp_t WHERE contractid=v_contractid
       ORDER BY gettime DESC LIMIT 0, 1; 
  IF v_volume IS NOT NULL THEN
    
    IF v_volume=0 THEN
      SET v_errorid=4;
    ELSEIF NOT v_currentprice=v_closeprice THEN
      SET v_errorid=1;
    END IF; 
       
  ELSE
    SET v_volume=NULL;
    SELECT currentprice, openprice, highprice, lowprice, closeprice, volume, openinterest, settlementprice
         INTO  v_currentprice, v_openprice, v_highprice, v_lowprice, v_closeprice, v_volume, v_openinterest, v_settlementprice
         FROM markettodaydata_t WHERE contractid=v_contractid 
         ORDER BY gettime DESC LIMIT 0, 1;
    
    IF v_volume IS NOT NULL THEN
      SET v_errorid=2; 
                
    ELSE 
      SET v_errorid=8;
      SET v_openprice=0;
      SET v_highprice=0;
      SET v_lowprice=0;
      SET v_closeprice=0;
      SET v_volume=0;
      SET v_openinterest=0;   
      SET v_settlementprice=0;                
          
    END IF; 
    SET done=false;
  END IF;
  
  INSERT marketdaydata_t
          VALUES(v_contractid, current_date, v_openprice, v_highprice, v_lowprice, v_closeprice, v_volume,
                 v_openinterest, v_settlementprice, v_errorid,NULL,NULL);    
  
  FETCH NEXT FROM cur_contract INTO v_contractid;
END WHILE;
CLOSE cur_contract;

DROP TABLE IF EXISTS todayvalidmarketdata_tmp_t;

INSERT marketrealtimedata_t SELECT * FROM markettodaydata_t;
TRUNCATE markettodaydata_t;

END top $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `computeparisvalid_p`
--

DROP PROCEDURE IF EXISTS `computeparisvalid_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `computeparisvalid_p`(
IN in_firstcontractid VARCHAR(10),
IN in_secondcontractid VARCHAR(10),
IN in_rightid VARCHAR(40),
OUT out_isvalid BOOL
)
label1:BEGIN

DECLARE v_firstmonth VARCHAR(4);
DECLARE v_secondmonth VARCHAR(4);
DECLARE v_month VARCHAR(4);
DECLARE v_volume DOUBLE;
DECLARE v_cancelmonth VARCHAR(40);
DECLARE v_mastermonth VARCHAR(40);
DECLARE v_delivermonth VARCHAR(40);
DECLARE v_commodityid VARCHAR(4); 
DECLARE v_datenum INT;
DECLARE v_monthdiff INT;


IF (in_firstcontractid IS NULL) OR (in_secondcontractid IS NULL) 
         OR (in_rightid IS NULL) THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


IF (in_firstcontractid NOT IN(SELECT contractid FROM validcontracts_t)) 
    OR (in_secondcontractid NOT IN(SELECT contractid FROM validcontracts_t)) THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


SET v_volume=(SELECT volume FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=in_firstcontractid);
IF v_volume<=50 THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;
SET v_volume=(SELECT volume FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=in_secondcontractid);
IF v_volume<=50 THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


IF (SELECT in_firstcontractid REGEXP BINARY '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
  SET v_datenum=3;
ELSE
  SET v_datenum=4;
END IF;
SET v_commodityid=LEFT(in_firstcontractid, LENGTH(in_firstcontractid)-v_datenum );


IF v_commodityid NOT IN (SELECT v_commodityid FROM validcommodities_t) THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


SET v_cancelmonth=(SELECT cancelmonth FROM commodity_t WHERE commodityid=v_commodityid);
SET v_mastermonth=(SELECT mastermonth FROM commodity_t WHERE commodityid=v_commodityid);
SET v_delivermonth=(SELECT delivermonth FROM commodity_t WHERE commodityid=v_commodityid);


IF v_mastermonth='0' THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


IF NOT IFNULL((SELECT isinstrumentsupport FROM commodityright_t WHERE rightid LIKE '01000101%' AND 
        firstcommodityid=v_commodityid AND secondcommodityid=v_commodityid), false) THEN
  SET out_isvalid=false;
  LEAVE label1;
END IF;


SET v_firstmonth=RIGHT(in_firstcontractid, 2);
SET v_secondmonth=RIGHT(in_secondcontractid, 2);


IF (SELECT in_rightid REGEXP BINARY '^01000101[0-9]{4}') THEN
  SET v_monthdiff=(INSTR(v_delivermonth, v_secondmonth)-INSTR(v_delivermonth, v_firstmonth));
  
  
  IF (v_monthdiff<0) AND NOT (ABS(v_monthdiff)=(LENGTH(v_delivermonth)-2)) THEN
     SET out_isvalid=false;
     LEAVE label1;
  ELSEIF (v_monthdiff>0) AND NOT (v_monthdiff=3) THEN
    SET out_isvalid=false;
    LEAVE label1;    
  END IF; 

ELSEIF (SELECT in_rightid REGEXP BINARY '^01000102[0-9]{4}') THEN
  IF NOT ((v_mastermonth REGEXP BINARY v_firstmonth) 
            AND (v_mastermonth REGEXP BINARY v_secondmonth)) THEN
    SET out_isvalid=false;
    LEAVE label1;           
  END IF;
ELSE
  SET out_isvalid=false;
  LEAVE label1;
END IF;


IF v_cancelmonth REGEXP BINARY '^2[0-9]{1}' THEN
  IF v_firstmonth>v_secondmonth THEN
     SET v_month=v_secondmonth+12;    
  ELSE
		 SET v_month=v_secondmonth;
  END IF;
  IF (v_month-v_firstmonth)>RIGHT(v_cancelmonth, 1) THEN
    SET out_isvalid=false;
    LEAVE label1;
  END IF;
ELSE
  
  SET v_month=v_firstmonth;
  IF v_firstmonth>v_secondmonth THEN
    WHILE v_month<='12' DO
      IF v_cancelmonth REGEXP BINARY v_month THEN
        SET out_isvalid=false;
        LEAVE label1;
      END IF;
      SET v_month=v_month+1;
      IF LENGTH(v_month)<2 THEN
      	SET v_month=CONCAT('0', v_month);
      END IF;
    END WHILE;
    SET v_month='01';
  END IF; 
  WHILE v_month<v_secondmonth DO
    IF v_cancelmonth REGEXP BINARY v_month THEN
      SET out_isvalid=false;
      LEAVE label1;
    END IF;
    SET v_month=v_month+1;
    IF LENGTH(v_month)<2 THEN
      SET v_month=CONCAT('0', v_month);
    END IF;   
  END WHILE; 
END IF;


SET out_isvalid=true;
END label1 $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updatecalendar_p`
--

DROP PROCEDURE IF EXISTS `updatecalendar_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatecalendar_p`(
IN d1 DATE,
IN d2 DATE,
IN d3 DATE,
IN d4 DATE,
IN d5 DATE,
IN d6 DATE,
IN d7 DATE,
IN d8 DATE,
IN d9 DATE,
IN d10 DATE,
IN d11 DATE,
IN d12 DATE,
IN d13 DATE,
IN d14 DATE,
IN d15 DATE,
IN d16 DATE,
IN d17 DATE,
IN d18 DATE,
IN d19 DATE,
IN d20 DATE,
IN d21 DATE,
IN d22 DATE,
IN d23 DATE,
IN d24 DATE,
IN d25 DATE,
IN d26 DATE,
IN d27 DATE,
IN d28 DATE,
IN d29 DATE,
IN d30 DATE
)
BEGIN

DECLARE v_order INT DEFAULT 0;
DECLARE v_date DATE;
DECLARE v_firstdate DATE;
DECLARE v_lastdate DATE;
DECLARE v_weekday INT;
DECLARE v_isworkday BOOL;
DECLARE v_done BOOL DEFAULT FALSE;
DECLARE cur_calendar CURSOR FOR SELECT everydate FROM exchangecalendar_t;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;



SET v_firstdate=DATE_SUB(d1, INTERVAL (DAYOFYEAR(d1)-1) DAY); 
SET v_lastdate=DATE_ADD(v_firstdate, INTERVAL 1 YEAR); 
SET v_date=v_firstdate;

SET v_order= IFNULL((SELECT orderid FROM exchangecalendar_t
WHERE everydate=DATE_SUB(d1, INTERVAL (DAYOFYEAR(d1)) DAY)),0);



IF (SELECT COUNT(orderid) FROM exchangecalendar_t WHERE everydate=d1)>0 THEN
  
  OPEN cur_calendar;
  FETCH cur_calendar INTO v_date;
  REPEAT
    IF (NOT v_done) AND (v_date<v_lastdate) AND (v_date>=v_firstdate) THEN
      SET v_weekday=WEEKDAY(v_date);
      
      IF (v_weekday IN (0,1,2,3,4)) AND (v_date NOT IN
                       (d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,
                        d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
                        d21,d22,d23,d24,d25,d26,d27,d28,d29,d30)) THEN
        SET v_order=v_order+1;
        SET v_isworkday=TRUE;
      ELSE
        SET v_isworkday=FALSE;
      END IF;
      UPDATE exchangecalendar_t
      SET weekday=v_weekday,
      isworkday=v_isworkday,
      orderid=v_order
      WHERE everydate=v_date;
    END IF;
    
  FETCH NEXT FROM cur_calendar INTO v_date;
  
  UNTIL v_done END REPEAT;
  
  CLOSE cur_calendar;

ELSE
  WHILE v_date<v_lastdate DO
    SET v_weekday=WEEKDAY(v_date);
    
    IF (v_weekday IN (0,1,2,3,4)) AND (v_date NOT IN
                     (d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,
                     d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
                     d21,d22,d23,d24,d25,d26,d27,d28,d29,d30)) THEN
      SET v_order=v_order+1;
      SET v_isworkday=TRUE;
    ELSE
      SET v_isworkday=FALSE;
    END IF;
    INSERT INTO exchangecalendar_t
    VALUE(v_date, v_order, v_isworkday, v_weekday);
    SET v_date=DATE_ADD(v_date, INTERVAL 1 DAY);
  END WHILE;
END IF;

END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updatecontractaftermarket_p`
--

DROP PROCEDURE IF EXISTS `updatecontractaftermarket_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatecontractaftermarket_p`()
top:BEGIN

DECLARE v_contractid VARCHAR(10);
DECLARE v_commodityid VARCHAR(4);
DECLARE v_exchangeid VARCHAR(10);
DECLARE v_tick FLOAT;
DECLARE v_datenum INT DEFAULT 4;
DECLARE v_lasttradedate DATE;
DECLARE v_startdeliverdate DATE;
DECLARE v_lastdeliverdate DATE;
DECLARE v_delivermargin FLOAT;
DECLARE v_exchmargin FLOAT DEFAULT 0;
DECLARE v_daystolasttradedate INT;
DECLARE v_daystolastdeliverdate INT;
DECLARE v_positionmargin FLOAT;
DECLARE v_priceuplimiteddays INT DEFAULT 0;
DECLARE v_pricedownlimiteddays INT DEFAULT 0;
DECLARE v_dailypricelimit FLOAT;
DECLARE v_pricelimitmargin FLOAT DEFAULT 0;
DECLARE v_thisworkdaycloseprice DOUBLE;
DECLARE v_thisworkdaysettlementprice DOUBLE;
DECLARE v_lastworkdaycloseprice DOUBLE;
DECLARE v_lastworkdaysettlementprice DOUBLE;
DECLARE v_uplimitprice DOUBLE;
DECLARE v_downlimitprice DOUBLE;
DECLARE v_thisworkdate DATE;
DECLARE v_lastworkdate DATE;
DECLARE v_nextworkdate DATE;
DECLARE v_isvalid BOOL;
DECLARE done INT DEFAULT 0;
DECLARE cur_contract CURSOR FOR SELECT contractid FROM validcontracts_t ORDER BY contractid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;






IF IFNULL((SELECT isworkday FROM exchangecalendar_t WHERE everydate=CURRENT_DATE),0)<>1 THEN
  LEAVE top;
END IF;


UPDATE contract_t SET isvalid=false;


CALL computedate_p(CURDATE(), '0401', v_thisworkdate);
DROP TABLE IF EXISTS thisworkdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  thisworkdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_thisworkdate;

CALL computedate_p(CURDATE(), '0402', v_lastworkdate);
DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  lastworkdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_lastworkdate;

CALL computedate_p(CURDATE(), '0501', v_nextworkdate);


OPEN cur_contract;
FETCH cur_contract INTO v_contractid;
REPEAT
  label1:BEGIN
    IF NOT done THEN

      CALL computecontractdate_p(v_contractid, v_lasttradedate, v_startdeliverdate, v_lastdeliverdate);


      IF (SELECT v_contractid REGEXP '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
        SET v_datenum=3;
      ELSE
        SET v_datenum=4;
      END IF;


      SET v_commodityid = LEFT(v_contractid, LENGTH(v_contractid)-v_datenum );


      IF(v_commodityid NOT IN (SELECT commodityid FROM validcommodities_t)) THEN
        SET done=false;
        LEAVE label1;
      END IF;

      SET v_exchmargin = (SELECT exchtrademargin FROM commodity_t WHERE commodityid=v_commodityid);


      IF IFNULL((SELECT errorid FROM thisworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid),0)>0 THEN
        SET v_isvalid=false;
      ELSE
        SET v_isvalid=true;
      END IF;





      SET v_daystolasttradedate=(datediff(v_lasttradedate, v_nextworkdate));
      SET v_daystolastdeliverdate=(datediff(v_startdeliverdate, v_nextworkdate));


      SET v_delivermargin=IFNULL((SELECT delivermargin FROM contractdelivermargin_t
                         WHERE v_nextworkdate>=actualdelivercheckdate AND contractid=v_contractid
                         ORDER BY checkid DESC LIMIT 0,1), 0);

      SET v_positionmargin=IFNULL((SELECT positionmargin FROM commoditypositionmargin_t
                         WHERE (positionthreshold*10000)<=(SELECT openinterest FROM thisworkdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid)
                         AND commodityid=v_commodityid
                         ORDER BY checkid DESC LIMIT 0,1), 0);

      SET v_uplimitprice=0;
      SET v_downlimitprice=0;

      IF (SELECT count(contractid) FROM contract_t WHERE contractid=v_contractid)>0 THEN

        SELECT  dailypricelimit, uplimitprice, downlimitprice INTO
                 v_dailypricelimit, v_uplimitprice, v_downlimitprice
                FROM contract_t WHERE contractid=v_contractid;



        SET v_priceuplimiteddays=0;
        SET v_pricedownlimiteddays=0;
        SET v_pricelimitmargin=0;

        SET v_lastworkdaycloseprice=NULL;
        SET v_lastworkdaysettlementprice=NULL;
        SET v_thisworkdaycloseprice=NULL;
        SET v_thisworkdaysettlementprice=NULL;
        SELECT closeprice, settlementprice INTO v_lastworkdaycloseprice, v_lastworkdaysettlementprice FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid;
        SELECT closeprice, settlementprice INTO v_thisworkdaycloseprice, v_thisworkdaysettlementprice FROM thisworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid;



   #     IF IFNULL((SELECT volume FROM thisworkdaymarketdaydata_tmp_t WHERE
   #                            contractid=v_contractid), 0)=0 THEN
          SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid);
   #     END IF;

        IF (SELECT count(contractid) FROM newcontracts_t WHERE contractid=v_contractid)>0 THEN
          IF IFNULL((SELECT volume FROM thisworkdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid), 0)=0 THEN
            SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid)*2;
          ELSE
            SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid);
            DELETE FROM newcontracts_t WHERE contractid=v_contractid;
          END IF;
        END IF;

        IF v_isvalid=true THEN

          IF((v_thisworkdaycloseprice>=v_uplimitprice) AND (v_uplimitprice <> 0)) THEN

            SET v_priceuplimiteddays=(SELECT priceuplimiteddays FROM contract_t WHERE contractid=v_contractid)+1;

            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_priceuplimiteddays;

          ELSEIF((v_thisworkdaycloseprice<=v_downlimitprice) AND (v_downlimitprice <> 0)) THEN

            SET v_pricedownlimiteddays=(SELECT pricedownlimiteddays FROM contract_t WHERE contractid=v_contractid)+1;

            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_pricedownlimiteddays;
		      ELSE
				    UPDATE contract_t, commodity_t
                   SET    contract_t.dailypricelimit=commodity_t.dailypricelimit
                   WHERE contract_t.commodityid=commodity_t.commodityid AND contract_t.contractid=v_contractid;
          END IF;
          SELECT tick, exchangeid INTO v_tick, v_exchangeid FROM commodity_t WHERE commodityid=v_commodityid;
          IF ((v_exchangeid='SH') OR (v_exchangeid='DL')) THEN
            SET v_uplimitprice=TRUNCATE(FLOOR((1+v_dailypricelimit)*v_thisworkdaysettlementprice/v_tick)*v_tick,2);
            SET v_downlimitprice=TRUNCATE(CEIL((1-v_dailypricelimit)*v_thisworkdaysettlementprice/v_tick)*v_tick,2);
          ELSEIF (v_exchangeid='ZZ') THEN
            SET v_uplimitprice=TRUNCATE(CEIL((1+v_dailypricelimit)*v_thisworkdaysettlementprice/v_tick)*v_tick,2);
            SET v_downlimitprice=TRUNCATE(FLOOR((1-v_dailypricelimit)*v_thisworkdaysettlementprice/v_tick)*v_tick,2);
          END IF;
        END IF;

        UPDATE contract_t SET
        commodityid=v_commodityid,
        lasttradedate=v_lasttradedate,
        startdeliverdate=v_startdeliverdate,
        lastdeliverdate=v_lastdeliverdate,
        delivermargin=v_delivermargin,
        daystolasttradedate=v_daystolasttradedate,
        daystolastdeliverdate=v_daystolastdeliverdate,
        positionmargin=v_positionmargin,
        priceuplimiteddays=v_priceuplimiteddays,
        pricedownlimiteddays=v_pricedownlimiteddays,
        pricelimitmargin=v_pricelimitmargin,
        dailypricelimit=v_dailypricelimit,
        uplimitprice=v_uplimitprice,
        downlimitprice=v_downlimitprice,
        updateddate=v_thisworkdate,
        isvalid=v_isvalid
        WHERE contractid=v_contractid;

        UPDATE  usercontract_t, usercommodity_t SET
        usercontract_t.contractmarginrate=(GREATEST(v_pricelimitmargin, v_positionmargin, v_delivermargin, v_exchmargin)
                   + usercommodity_t.trademargingap)
        WHERE usercontract_t.userid=usercommodity_t.userid
              and contractid=v_contractid
              and usercontract_t.commodityid=usercommodity_t.commodityid;
      ELSE
        INSERT INTO newcontracts_t VALUES(v_contractid);
        INSERT INTO contract_t(contractid, commodityid, ishavespecpositions, lasttradedate,
        startdeliverdate, lastdeliverdate, delivermargin, daystolasttradedate,
        daystolastdeliverdate, positionmargin, isvalid, priceuplimiteddays, pricedownlimiteddays,
        pricelimitmargin, uplimitprice, downlimitprice, updateddate)
        VALUES(v_contractid, v_commodityid, false, v_lasttradedate,
        v_startdeliverdate, v_lastdeliverdate, v_delivermargin, v_daystolasttradedate,
        v_daystolastdeliverdate, v_positionmargin, v_isvalid, 0, 0,
        0, 0, 0, v_thisworkdate);

        UPDATE contract_t, commodity_t
        SET contract_t.tradeunit=commodity_t.tradeunit,
        contract_t.todayexitdiscount=commodity_t.todayexitdiscount,
        contract_t.issinglemargin=commodity_t.issinglemargin,
        contract_t.exchtrademargin=commodity_t.exchtrademargin,
        contract_t.exchtradechargetype=commodity_t.exchtradechargetype,
        contract_t.exchtradecharge=commodity_t.exchtradecharge,
        contract_t.dailypricelimit=commodity_t.dailypricelimit*2
        WHERE contract_t.commodityid=commodity_t.commodityid AND contract_t.contractid=v_contractid;
        INSERT usercontract_t SELECT v_contractid, userid, v_commodityid, v_isvalid, 0,
           (SELECT lendrate FROM usercommodity_t cm where cm.userid=ur.userid AND cm.commodityid=v_commodityid)
        FROM user_t AS ur;
      END IF;
      SET done=false;
    END IF;
  END label1;

  FETCH NEXT FROM cur_contract INTO v_contractid;

UNTIL done END REPEAT;


CLOSE cur_contract;


DROP TABLE IF EXISTS thisworkdaymarketdaydata_tmp_t;
DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;


call updateorderidinmarketdaydata_p();

call updateserialcotract_p();
END top $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updatecontractbeforemarket_p`
--

DROP PROCEDURE IF EXISTS `updatecontractbeforemarket_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatecontractbeforemarket_p`()
top:BEGIN

DECLARE v_contractid VARCHAR(10);
DECLARE v_commodityid VARCHAR(4);
DECLARE v_exchangeid VARCHAR(10);
DECLARE v_tick FLOAT;
DECLARE v_datenum INT DEFAULT 4;
DECLARE v_lasttradedate DATE;
DECLARE v_startdeliverdate DATE;
DECLARE v_lastdeliverdate DATE;
DECLARE v_delivermargin FLOAT;
DECLARE v_exchmargin FLOAT DEFAULT 0;
DECLARE v_daystolasttradedate INT;
DECLARE v_daystolastdeliverdate INT;
DECLARE v_positionmargin FLOAT;
DECLARE v_priceuplimiteddays INT DEFAULT 0;
DECLARE v_pricedownlimiteddays INT DEFAULT 0;
DECLARE v_dailypricelimit FLOAT;
DECLARE v_pricelimitmargin FLOAT DEFAULT 0;
DECLARE v_last2workdaysettlementprice DOUBLE;
DECLARE v_lastworkdaycloseprice DOUBLE;
DECLARE v_lastworkdaysettlementprice DOUBLE;
DECLARE v_uplimitprice DOUBLE;
DECLARE v_downlimitprice DOUBLE;
DECLARE v_lastworkdate DATE;
DECLARE v_last2workdate DATE;
DECLARE v_updateddate DATE;
DECLARE v_isvalid BOOL;
DECLARE done INT DEFAULT 0;
DECLARE cur_contract CURSOR FOR SELECT contractid FROM validcontracts_t;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;





IF IFNULL((SELECT isworkday FROM exchangecalendar_t WHERE everydate=CURRENT_DATE),0)<>1 THEN
  LEAVE top;
END IF;



CALL computedate_p(CURDATE(), '0402', v_lastworkdate);
DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  lastworkdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_lastworkdate;

CALL computedate_p(CURDATE(), '0403', v_last2workdate);
DROP TABLE IF EXISTS last2workdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  last2workdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_last2workdate;


OPEN cur_contract;
FETCH cur_contract INTO v_contractid;
REPEAT
  label1:BEGIN
    IF NOT done THEN

      CALL computecontractdate_p(v_contractid, v_lasttradedate, v_startdeliverdate, v_lastdeliverdate);


      IF (SELECT v_contractid REGEXP '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
        SET v_datenum=3;
      ELSE
        SET v_datenum=4;
      END IF;


      SET v_commodityid = LEFT(v_contractid, LENGTH(v_contractid)-v_datenum );


      IF(v_commodityid NOT IN (SELECT commodityid FROM validcommodities_t)) THEN
        SET done=false;
        LEAVE label1;
      END IF;

      SET v_exchmargin = (SELECT exchtrademargin FROM commodity_t WHERE commodityid=v_commodityid);

      IF IFNULL((SELECT errorid FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid),0)>0 THEN
        SET v_isvalid=false;
      ELSE
        SET v_isvalid=true;
      END IF;





      SET v_daystolasttradedate=(datediff(v_lasttradedate, CURDATE()));
      SET v_daystolastdeliverdate=(datediff(v_startdeliverdate, CURDATE()));


      SET v_delivermargin=IFNULL((SELECT delivermargin FROM contractdelivermargin_t
                         WHERE CURDATE()>=actualdelivercheckdate AND contractid=v_contractid
                         ORDER BY checkid DESC LIMIT 0,1), 0);

      SET v_positionmargin=IFNULL((SELECT positionmargin FROM commoditypositionmargin_t
                         WHERE (positionthreshold*10000)<=(SELECT openinterest FROM lastworkdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid)
                         AND commodityid=v_commodityid
                         ORDER BY checkid DESC LIMIT 0,1), 0);

      IF (v_commodityid='cu' OR v_commodityid='al' OR v_commodityid='zn' OR v_commodityid='au' OR v_commodityid='rb' OR v_commodityid='wr' OR v_commodityid='rb') AND ((LEFT(RIGHT(v_contractid,4),2)-RIGHT(YEAR(now()),2))*12+RIGHT(v_contractid,2)-3>MONTH(now())) THEN
      SET v_positionmargin=IFNULL((SELECT positionmargin FROM commoditypositionmargin_t
                         WHERE checkid=0
                         AND commodityid=v_commodityid
                         ORDER BY checkid DESC LIMIT 0,1), 0);
      END IF;

      SET v_uplimitprice=0;
      SET v_downlimitprice=0;
      SET v_updateddate=NULL;

      IF (SELECT count(contractid) FROM contract_t WHERE contractid=v_contractid)>0 THEN

        SELECT  dailypricelimit, uplimitprice, downlimitprice, updateddate INTO
                 v_dailypricelimit, v_uplimitprice, v_downlimitprice, v_updateddate
                FROM contract_t WHERE contractid=v_contractid;



        SET v_priceuplimiteddays=0;
        SET v_pricedownlimiteddays=0;
        SET v_pricelimitmargin=0;
        SET v_last2workdaysettlementprice=(SELECT settlementprice FROM last2workdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid);
        SET v_lastworkdaycloseprice=NULL;
        SET v_lastworkdaysettlementprice=NULL;
        SELECT closeprice, settlementprice INTO v_lastworkdaycloseprice, v_lastworkdaysettlementprice FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid;

   #     IF IFNULL((SELECT volume FROM lastworkdaymarketdaydata_tmp_t WHERE
   #                             contractid=v_contractid), 0)=0 THEN
          SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid);
   #    END IF;

        IF (SELECT count(contractid) FROM newcontracts_t WHERE contractid=v_contractid)>0 THEN
          IF IFNULL((SELECT volume FROM lastworkdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid), 0)=0 THEN
            SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid)*2;
          ELSE
            SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid);
            DELETE FROM newcontracts_t WHERE contractid=v_contractid;
          END IF;
        END IF;

        IF v_isvalid=true THEN
          IF(SELECT closeprice FROM lastworkdaymarketdaydata_tmp_t WHERE v_lastworkdaycloseprice>=(1+v_dailypricelimit)*v_last2workdaysettlementprice
                     AND contractid=v_contractid) IS NOT NULL THEN

            SET v_priceuplimiteddays=(SELECT priceuplimiteddays FROM contract_t WHERE contractid=v_contractid)+1;

            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_priceuplimiteddays;
          ELSEIF (SELECT closeprice FROM lastworkdaymarketdaydata_tmp_t WHERE v_lastworkdaycloseprice<=(1-v_dailypricelimit)*v_last2workdaysettlementprice
                     AND contractid=v_contractid) IS NOT NULL THEN

            SET v_pricedownlimiteddays=(SELECT pricedownlimiteddays FROM contract_t WHERE contractid=v_contractid)+1;

            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_pricedownlimiteddays;
          ELSE
            UPDATE contract_t, commodity_t
            SET contract_t.dailypricelimit=commodity_t.dailypricelimit
                   WHERE contract_t.commodityid=commodity_t.commodityid AND contract_t.contractid=v_contractid;
          END IF;
          
          SELECT tick, exchangeid INTO v_tick, v_exchangeid FROM commodity_t WHERE commodityid=v_commodityid;
          IF ((v_exchangeid='SH') OR (v_exchangeid='DL')) THEN
            SET v_uplimitprice=TRUNCATE(FLOOR((1+v_dailypricelimit)*v_lastworkdaysettlementprice/v_tick)*v_tick,2);
            SET v_downlimitprice=TRUNCATE(CEIL((1-v_dailypricelimit)*v_lastworkdaysettlementprice/v_tick)*v_tick,2);
          ELSEIF (v_exchangeid='ZZ') THEN
            SET v_uplimitprice=TRUNCATE(CEIL((1+v_dailypricelimit)*v_lastworkdaysettlementprice/v_tick)*v_tick,2);
            SET v_downlimitprice=TRUNCATE(FLOOR((1-v_dailypricelimit)*v_lastworkdaysettlementprice/v_tick)*v_tick,2);          
          END IF;
        END IF;



        UPDATE contract_t SET
        commodityid=v_commodityid,
        lasttradedate=v_lasttradedate,
        startdeliverdate=v_startdeliverdate,
        lastdeliverdate=v_lastdeliverdate,
        delivermargin=v_delivermargin,
        daystolasttradedate=v_daystolasttradedate,
        daystolastdeliverdate=v_daystolastdeliverdate,
        positionmargin=v_positionmargin,
        priceuplimiteddays=v_priceuplimiteddays,
        pricedownlimiteddays=v_pricedownlimiteddays,
        pricelimitmargin=v_pricelimitmargin,
        dailypricelimit=v_dailypricelimit,
        uplimitprice=TRUNCATE(v_uplimitprice, 2),
        downlimitprice=TRUNCATE(v_downlimitprice, 2),
        updateddate=v_lastworkdate,
        isvalid=v_isvalid
        WHERE contractid=v_contractid;

        UPDATE  usercontract_t, usercommodity_t SET
        usercontract_t.contractmarginrate=(GREATEST(v_pricelimitmargin, v_positionmargin, v_delivermargin, v_exchmargin)
                   + usercommodity_t.trademargingap)
        WHERE usercontract_t.userid=usercommodity_t.userid
              and contractid=v_contractid
              and usercontract_t.commodityid=usercommodity_t.commodityid;
        
        UPDATE contract_t SET
        isvalid=((v_isvalid) AND (contract_t.isvalid))
        WHERE contractid=v_contractid;
        

      ELSE
        INSERT INTO newcontracts_t VALUES(v_contractid);
        INSERT INTO contract_t(contractid, commodityid, ishavespecpositions, lasttradedate,
        startdeliverdate, lastdeliverdate, delivermargin, daystolasttradedate,
        daystolastdeliverdate, positionmargin, isvalid, priceuplimiteddays, pricedownlimiteddays,
        pricelimitmargin, uplimitprice, downlimitprice,updateddate)
        VALUES(v_contractid, v_commodityid, false, v_lasttradedate,
        v_startdeliverdate, v_lastdeliverdate, v_delivermargin, v_daystolasttradedate,
        v_daystolastdeliverdate, v_positionmargin, v_isvalid, 0, 0,
        0, 0, 0, v_lastworkdate);

        UPDATE contract_t, commodity_t
        SET contract_t.tradeunit=commodity_t.tradeunit,
        contract_t.todayexitdiscount=commodity_t.todayexitdiscount,
        contract_t.issinglemargin=commodity_t.issinglemargin,
        contract_t.exchtrademargin=commodity_t.exchtrademargin,
        contract_t.exchtradechargetype=commodity_t.exchtradechargetype,
        contract_t.exchtradecharge=commodity_t.exchtradecharge,
        contract_t.dailypricelimit=commodity_t.dailypricelimit*2
        WHERE contract_t.commodityid=commodity_t.commodityid AND contract_t.contractid=v_contractid;
        INSERT usercontract_t SELECT v_contractid, userid, v_commodityid, v_isvalid, 0,
           (SELECT lendrate FROM usercommodity_t cm where cm.userid=ur.userid AND cm.commodityid=v_commodityid)
        FROM user_t AS ur;
      END IF;
      SET done = false;
    END IF;
  END label1;

  FETCH NEXT FROM cur_contract INTO v_contractid;
  
UNTIL done END REPEAT;


CLOSE cur_contract;


DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
DROP TABLE IF EXISTS last2workdaymarketdaydata_tmp_t;

END top $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updatecontract_p`
--

DROP PROCEDURE IF EXISTS `updatecontract_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatecontract_p`()
BEGIN

DECLARE v_contractid VARCHAR(10);
DECLARE v_commodityid VARCHAR(4);
DECLARE v_datenum INT DEFAULT 4;
DECLARE v_lasttradedate DATE;
DECLARE v_startdeliverdate DATE;
DECLARE v_lastdeliverdate DATE;
DECLARE v_delivermargin FLOAT;
DECLARE v_daystolasttradedate INT;
DECLARE v_daystolastdeliverdate INT;
DECLARE v_positionmargin FLOAT;
DECLARE v_priceuplimiteddays INT DEFAULT 0;
DECLARE v_pricedownlimiteddays INT DEFAULT 0;
DECLARE v_dailypricelimit FLOAT;
DECLARE v_pricelimitmargin FLOAT DEFAULT 0;
DECLARE v_last2workdaysettlementprice DOUBLE;
DECLARE v_lastworkdaycloseprice DOUBLE;
DECLARE v_lastworkdaysettlementprice DOUBLE;
DECLARE v_uplimitprice DOUBLE;
DECLARE v_downlimitprice DOUBLE;
DECLARE v_lastworkdate DATE;
DECLARE v_last2workdate DATE;
DECLARE v_isvalid BOOL;
DECLARE done INT DEFAULT 0;
DECLARE cur_contract CURSOR FOR SELECT contractid FROM validcontracts_t;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;






UPDATE contract_t SET isvalid=false;


CALL computedate_p(CURDATE(), '0402', v_lastworkdate);
DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  lastworkdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_lastworkdate;

CALL computedate_p(CURDATE(), '0403', v_last2workdate);
DROP TABLE IF EXISTS last2workdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  last2workdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_last2workdate;


OPEN cur_contract;
FETCH cur_contract INTO v_contractid;
REPEAT
  label1:BEGIN
    IF NOT done THEN
      
      CALL computecontractdate_p(v_contractid, v_lasttradedate, v_startdeliverdate, v_lastdeliverdate);
      
      
      IF (SELECT v_contractid REGEXP '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
        SET v_datenum=3;
      ELSE
        SET v_datenum=4;
      END IF;
      
      
      IF (SELECT v_contractid REGEXP '^(WT|b)') THEN
        LEAVE label1;
      END IF;
 
      
      IF IFNULL((SELECT errorid FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid),0)>0 THEN
        SET v_isvalid=false;
      ELSE
        SET v_isvalid=true;        
      END IF;

      
      SET v_commodityid = LEFT(v_contractid, LENGTH(v_contractid)-v_datenum );

      
      
      
      
      SET v_daystolasttradedate=(datediff(v_lasttradedate, CURDATE()));
      SET v_daystolastdeliverdate=(datediff(v_startdeliverdate, CURDATE()));                       
                             
      
      SET v_delivermargin=IFNULL((SELECT delivermargin FROM contractdelivermargin_t 
                         WHERE CURDATE()>=actualdelivercheckdate AND contractid=v_contractid 
                         ORDER BY checkid DESC LIMIT 0,1), 0);
      
      SET v_positionmargin=IFNULL((SELECT positionmargin FROM commoditypositionmargin_t
                         WHERE positionthreshold<=(SELECT openinterest FROM lastworkdaymarketdaydata_tmp_t WHERE 
                                contractid=v_contractid)
                         AND commodityid=v_commodityid 
                         ORDER BY checkid DESC LIMIT 0,1), 0);

      
      IF (SELECT count(contractid) FROM contract_t WHERE contractid=v_contractid)>0 THEN
        
        SELECT  dailypricelimit INTO
                 v_dailypricelimit
                FROM contract_t WHERE contractid=v_contractid;
  
        
        
        SET v_priceuplimiteddays=0;
        SET v_pricedownlimiteddays=0;
        SET v_last2workdaysettlementprice=(SELECT settlementprice FROM last2workdaymarketdaydata_tmp_t WHERE
                                contractid=v_contractid);
        SET v_lastworkdaycloseprice=NULL;
        SET v_lastworkdaysettlementprice=NULL;                        
        SELECT closeprice, settlementprice INTO v_lastworkdaycloseprice, v_lastworkdaysettlementprice FROM lastworkdaymarketdaydata_tmp_t WHERE contractid=v_contractid;
        
        IF IFNULL((SELECT volume FROM lastworkdaymarketdaydata_tmp_t WHERE 
                                contractid=v_contractid), 0)=0 THEN
          SET v_dailypricelimit=(SELECT dailypricelimit FROM commodity_t WHERE commodityid=v_commodityid);
        END IF;
        
        IF v_isvalid=true THEN
          IF(SELECT closeprice FROM lastworkdaymarketdaydata_tmp_t WHERE v_lastworkdaycloseprice>=(1+v_dailypricelimit)*v_last2workdaysettlementprice 
                     AND contractid=v_contractid) IS NOT NULL THEN
            
            SET v_priceuplimiteddays=(SELECT priceuplimiteddays FROM contract_t WHERE contractid=v_contractid)+1;
            
            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_priceuplimiteddays;
          ELSEIF (SELECT closeprice FROM lastworkdaymarketdaydata_tmp_t WHERE v_lastworkdaycloseprice<=(1-v_dailypricelimit)*v_last2workdaysettlementprice
                     AND contractid=v_contractid) IS NOT NULL THEN
            
            SET v_pricedownlimiteddays=(SELECT pricedownlimiteddays FROM contract_t WHERE contractid=v_contractid)+1;
            
            SELECT exchtrademargin, dailypricelimit INTO v_pricelimitmargin, v_dailypricelimit FROM commoditypricelimit_t
                   WHERE commodityid=v_commodityid AND priceuplimiteddays=v_pricedownlimiteddays;
          END IF;
          SET v_uplimitprice=(1+v_dailypricelimit)*v_lastworkdaysettlementprice;
          SET v_downlimitprice=(1-v_dailypricelimit)*v_lastworkdaysettlementprice;
        END IF; 
        
        UPDATE contract_t SET 
        commodityid=v_commodityid,
        lasttradedate=v_lasttradedate,
        startdeliverdate=v_startdeliverdate,
        lastdeliverdate=v_lastdeliverdate,
        delivermargin=v_delivermargin,
        daystolasttradedate=v_daystolasttradedate,
        daystolastdeliverdate=v_daystolastdeliverdate,
        positionmargin=v_positionmargin,
        priceuplimiteddays=v_priceuplimiteddays,
        pricedownlimiteddays=v_pricedownlimiteddays,
        pricelimitmargin=v_pricelimitmargin,
        dailypricelimit=v_dailypricelimit,
        uplimitprice=TRUNCATE(v_uplimitprice, 2),
        downlimitprice=TRUNCATE(v_downlimitprice, 2),
        isvalid=true
        WHERE contractid=v_contractid;
        
        UPDATE  usercontract_t, usercommodity_t SET
        usercontract_t.contractmarginrate=(GREATEST(v_pricelimitmargin, v_positionmargin, v_delivermargin)
                   + usercommodity_t.trademargingap)
        WHERE usercontract_t.userid=usercommodity_t.userid
              and contractid=v_contractid 
              and usercontract_t.commodityid=usercommodity_t.commodityid;                
      ELSE     
        INSERT INTO contract_t(contractid, commodityid, ishavespecpositions, lasttradedate,
        startdeliverdate, lastdeliverdate, delivermargin, daystolasttradedate,
        daystolastdeliverdate, positionmargin, isvalid, priceuplimiteddays, pricedownlimiteddays,
        pricelimitmargin, uplimitprice, downlimitprice)
        VALUES(v_contractid, v_commodityid, false, v_lasttradedate,
        v_startdeliverdate, v_lastdeliverdate, v_delivermargin, v_daystolasttradedate,
        v_daystolastdeliverdate, v_positionmargin, v_isvalid, 0, 0,
        0, 0, 0);
        
        UPDATE contract_t, commodity_t
        SET contract_t.tradeunit=commodity_t.tradeunit,
        contract_t.todayexitdiscount=commodity_t.todayexitdiscount,
        contract_t.issinglemargin=commodity_t.issinglemargin,
        contract_t.exchtrademargin=commodity_t.exchtrademargin,
        contract_t.exchtradechargetype=commodity_t.exchtradechargetype,
        contract_t.exchtradecharge=commodity_t.exchtradecharge,
        contract_t.dailypricelimit=commodity_t.dailypricelimit
        WHERE contract_t.commodityid=commodity_t.commodityid AND contract_t.contractid=v_contractid;
        INSERT usercontract_t SELECT v_contractid, userid, v_commodityid, v_isvalid, 0,
           (SELECT lendrate FROM usercommodity_t cm where cm.userid=ur.userid AND cm.commodityid=v_commodityid)
        FROM user_t AS ur;
      END IF;
    END IF;
  END label1;
  
  FETCH NEXT FROM cur_contract INTO v_contractid;
  
UNTIL done END REPEAT;


CLOSE cur_contract;


DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
DROP TABLE IF EXISTS last2workdaymarketdaydata_tmp_t;

END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updateorderidinmarketdaydata_p`
--

DROP PROCEDURE IF EXISTS `updateorderidinmarketdaydata_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateorderidinmarketdaydata_p`()
BEGIN
DECLARE v_orderid INT;
DECLARE v_contractid VARCHAR(10);
DECLARE v_currentdate DATE;
DECLARE v_done BOOL DEFAULT false;
DECLARE cur_marketdaydata CURSOR FOR SELECT contractid, currentdate FROM marketdaydata_t WHERE orderid is NULL 
                          ORDER BY currentdate;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;


update marketdaydata_t, contract_t
set marketdaydata_t.commodityid=contract_t.commodityid
where marketdaydata_t.contractid=contract_t.contractid;


OPEN cur_marketdaydata;
FETCH cur_marketdaydata INTO v_contractid, v_currentdate;
WHILE NOT v_done DO
  
  SET v_orderid=(SELECT max(orderid) FROM marketdaydata_t WHERE contractid=v_contractid
  AND currentdate<v_currentdate);
  
  IF (v_orderid is NULL) THEN
    SET v_orderid=1;
  ELSE
    SET v_orderid=v_orderid+1;
  END IF;
  
  UPDATE marketdaydata_t
  SET orderid=v_orderid
  WHERE contractid=v_contractid
  AND currentdate=v_currentdate;
  
  FETCH NEXT FROM cur_marketdaydata INTO v_contractid, v_currentdate; 
END WHILE;


END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updateorderidinrawmarketdata_p`
--

DROP PROCEDURE IF EXISTS `updateorderidinrawmarketdata_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateorderidinrawmarketdata_p`(
IN in_contractid VARCHAR(10)
)
BEGIN
SET @v_orderid:=0;
update rawdailydata_t a inner join
(select @v_orderid:=@v_orderid+1 as k, contractmonth, currentdate from rawdailydata_t where contractmonth=in_contractid ) b
on a.contractmonth=b.contractmonth and a.currentdate=b.currentdate and a.contractmonth=in_contractid
set a.orderid=b.k;

END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updatepairs_p`
--

DROP PROCEDURE IF EXISTS `updatepairs_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatepairs_p`()
top:BEGIN
DECLARE v_beforecontractid VARCHAR(10);
DECLARE v_master1stcontractid VARCHAR(10);
DECLARE v_master2ndcontractid VARCHAR(10);
DECLARE v_master3rdcontractid VARCHAR(10);
DECLARE v_currentcontractid VARCHAR(10);
DECLARE v_previouscommodityid VARCHAR(4);
DECLARE v_currentcommodityid VARCHAR(4);
DECLARE v_rightid VARCHAR(40);
DECLARE v_isinstrumentsupport BOOL;
DECLARE v_isvalid BOOL;
DECLARE v_datenum INT;
DECLARE done INT DEFAULT 0;
DECLARE v_lastworkdate DATE;
DECLARE cur_contract CURSOR FOR SELECT contractid FROM validcontracts_t ORDER BY contractid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

IF IFNULL((SELECT isworkday FROM exchangecalendar_t WHERE everydate=CURRENT_DATE),0)<>1 THEN
  LEAVE top;
END IF;

DELETE FROM arbitragecontractpairs_t WHERE rightid LIKE '0100010%';

CALL computedate_p(CURDATE(), '0402', v_lastworkdate);
DROP TABLE IF EXISTS lastworkdaymarketdaydata_tmp_t;
CREATE TEMPORARY TABLE  lastworkdaymarketdaydata_tmp_t select * from marketdaydata_t
WHERE marketdaydata_t.currentdate=v_lastworkdate;


OPEN cur_contract;
FETCH cur_contract INTO v_currentcontractid;
WHILE NOT done DO
  
  IF (SELECT v_currentcontractid REGEXP BINARY '^(CF|ER|RO|SR|TA|WS|WT|ME|OI|WH|RI)[0-9]{3}$') THEN
    SET v_datenum=3;
  ELSE
    SET v_datenum=4;
  END IF;
  SET v_currentcommodityid=LEFT(v_currentcontractid, LENGTH(v_currentcontractid)-v_datenum );

  
  IF v_currentcommodityid=v_previouscommodityid THEN
    
      SET v_rightid=(SELECT rightid
             FROM commodityright_t WHERE rightid LIKE '01000101%' AND 
             firstcommodityid=v_currentcommodityid AND secondcommodityid=v_currentcommodityid);     
      CALL computeparisvalid_p(v_beforecontractid, v_currentcontractid, v_rightid, v_isvalid);
      IF v_isvalid THEN
        INSERT INTO arbitragecontractpairs_t(firstcontractid,secondcontractid,rightid)
                   VALUES(v_beforecontractid, v_currentcontractid, v_rightid);
      END IF;
    
  ELSE
    
      SET v_rightid=(SELECT rightid
             FROM commodityright_t WHERE rightid LIKE '01000102%' AND 
             firstcommodityid=v_currentcommodityid AND secondcommodityid=v_currentcommodityid);
      IF v_currentcommodityid='au' THEN
        
        SET v_master1stcontractid=IFNULL((SELECT contractid FROM (SELECT contractid FROM lastworkdaymarketdaydata_tmp_t 
                   WHERE contractid REGEXP BINARY CONCAT('^', v_currentcommodityid, '[0-9]') 
                   ORDER BY volume DESC LIMIT 0, 2) as alias_t ORDER BY alias_t.contractid LIMIT 0, 1), NULL);
        
        SET v_master2ndcontractid=IFNULL((SELECT contractid FROM (SELECT contractid FROM lastworkdaymarketdaydata_tmp_t 
                   WHERE contractid REGEXP BINARY CONCAT('^', v_currentcommodityid, '[0-9]') 
                   ORDER BY volume DESC LIMIT 0, 2) as alias_t ORDER BY alias_t.contractid LIMIT 1, 1), NULL);
        
        SET v_master3rdcontractid=NULL;
      ELSE
        
        SET v_master1stcontractid=IFNULL((SELECT contractid FROM (SELECT contractid FROM lastworkdaymarketdaydata_tmp_t 
                   WHERE contractid REGEXP BINARY CONCAT('^', v_currentcommodityid, '[0-9]') 
                   ORDER BY volume DESC LIMIT 0, 3) as alias_t ORDER BY alias_t.contractid LIMIT 0, 1), NULL);
        
        SET v_master2ndcontractid=IFNULL((SELECT contractid FROM (SELECT contractid FROM lastworkdaymarketdaydata_tmp_t 
                   WHERE contractid REGEXP BINARY CONCAT('^', v_currentcommodityid, '[0-9]') 
                   ORDER BY volume DESC LIMIT 0, 3) as alias_t ORDER BY alias_t.contractid LIMIT 1, 1), NULL);
        
        SET v_master3rdcontractid=IFNULL((SELECT contractid FROM (SELECT contractid FROM lastworkdaymarketdaydata_tmp_t 
                   WHERE contractid REGEXP BINARY CONCAT('^', v_currentcommodityid, '[0-9]')
                   ORDER BY volume DESC LIMIT 0, 3) as alias_t ORDER BY alias_t.contractid LIMIT 2, 1), NULL);
      END IF;
      
       
      CALL computeparisvalid_p(v_master1stcontractid, v_master2ndcontractid, v_rightid, v_isvalid);
      IF v_isvalid THEN 
        INSERT INTO arbitragecontractpairs_t(firstcontractid,secondcontractid,rightid)
               VALUES(v_master1stcontractid, v_master2ndcontractid, v_rightid);
        
        CALL computeparisvalid_p(v_master2ndcontractid, v_master3rdcontractid, v_rightid, v_isvalid);
        IF v_isvalid THEN 
          INSERT INTO arbitragecontractpairs_t(firstcontractid,secondcontractid,rightid)
                 VALUES(v_master2ndcontractid, v_master3rdcontractid, v_rightid);
        END IF;
      ELSE
        
        CALL computeparisvalid_p(v_master2ndcontractid, v_master3rdcontractid, v_rightid, v_isvalid);
        IF v_isvalid THEN 
          INSERT INTO arbitragecontractpairs_t(firstcontractid,secondcontractid,rightid)
                 VALUES(v_master2ndcontractid, v_master3rdcontractid, v_rightid);
        ELSE
          
          CALL computeparisvalid_p(v_master1stcontractid, v_master3rdcontractid, v_rightid, v_isvalid);
          IF v_isvalid THEN 
            INSERT INTO arbitragecontractpairs_t(firstcontractid,secondcontractid,rightid)
                   VALUES(v_master1stcontractid, v_master3rdcontractid, v_rightid);  
          END IF;
        END IF;
      END IF;     
    
       
    SET v_previouscommodityid=v_currentcommodityid;   
  END IF;
  
  SET v_beforecontractid=v_currentcontractid;
  
  FETCH NEXT FROM cur_contract INTO v_currentcontractid;
END WHILE; 


CLOSE cur_contract;

END top $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updateserialcotractfromhistory_p`
--

DROP PROCEDURE IF EXISTS `updateserialcotractfromhistory_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateserialcotractfromhistory_p`(
IN in_commodityid1 VARCHAR(4),IN in_commodityid2 VARCHAR(4)
)
BEGIN

DECLARE v_contractmonth VARCHAR(10);
DECLARE v_currentcontractmonth VARCHAR(10);
DECLARE v_previouscontractmonth VARCHAR(10);
DECLARE v_currentcloseprice DOUBLE DEFAULT 0;
DECLARE v_pricegap DOUBLE DEFAULT 0;
DECLARE v_currentdate DATE;
DECLARE v_exchangeid VARCHAR(10);
DECLARE v_volume BIGINT;
DECLARE v_closepricegap DOUBLE;
DECLARE v_counter INT DEFAULT 0;
DECLARE v_done BOOL DEFAULT false;
DECLARE cur_serialcontract CURSOR FOR SELECT contractid, currentdate, closeprice FROM
       (SELECT contractid, currentdate, closeprice, commodityid FROM marketdaydata_t sub
              WHERE (commodityid=in_commodityid1 OR commodityid=in_commodityid2)  ORDER BY sub.currentdate, sub.volume DESC ) mst
        GROUP BY mst.currentdate;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;


DROP TABLE IF EXISTS temprawdata_tmp_t;
CREATE TEMPORARY TABLE  temprawdata_tmp_t select * from marketdaydata_t
WHERE (commodityid=in_commodityid1 OR commodityid=in_commodityid2);



OPEN cur_serialcontract;
FETCH cur_serialcontract INTO v_currentcontractmonth, v_currentdate, v_currentcloseprice;
SET v_contractmonth=v_currentcontractmonth;
SET v_previouscontractmonth=v_currentcontractmonth;
SET v_pricegap=0;
WHILE NOT v_done DO
  
  IF ((RIGHT(v_currentcontractmonth,2)=MONTH(v_currentdate))
      &&(LEFT(RIGHT(v_contractmonth,3),1)=MOD(YEAR(v_currentdate),10))) THEN
    
      SET v_currentcontractmonth=(SELECT contractid from temprawdata_tmp_t where
                         currentdate=v_currentdate and contractid<>v_currentcontractmonth order by volume DESC LIMIT 0,1 );
    
    
    SET v_contractmonth=v_currentcontractmonth;               
    SET v_previouscontractmonth=v_currentcontractmonth;
    SET v_counter=0;
  END IF;

  IF(v_counter>0) THEN
    
    IF(v_counter>=5) THEN                                              
      
      SET v_closepricegap=(SELECT after_t.closeprice-before_t.closeprice
           FROM temprawdata_tmp_t as before_t,marketdaydata_t as after_t
           WHERE before_t.contractid=v_contractmonth
           AND after_t.contractid=v_previouscontractmonth
           AND after_t.currentdate=before_t.currentdate          
           AND before_t.currentdate<=v_currentdate
           AND after_t.currentdate<=v_currentdate
           ORDER BY before_t.currentdate DESC
           LIMIT 0,1);
      
      SET v_pricegap=v_pricegap+v_closepricegap;
      SET v_contractmonth=v_previouscontractmonth;               
      SET v_counter=0;
      
      IF(v_previouscontractmonth<>v_currentcontractmonth) THEN
        SET v_counter=1;
      END IF;
    ELSEIF(v_previouscontractmonth=v_currentcontractmonth) THEN
      SET v_counter=v_counter+1;
    ELSEIF(v_currentcontractmonth=v_contractmonth) THEN
      SET v_counter=0;
    ELSE
      SET v_counter=1;
    END IF;
  ELSE

    IF(v_previouscontractmonth<>v_currentcontractmonth) THEN
      SET v_counter=1;
    END IF;
  END IF;
  
  
  SET v_previouscontractmonth=v_currentcontractmonth;
  IF(SELECT currentdate FROM serialdailydata_t WHERE currentdate=v_currentdate
            AND (commodityid=in_commodityid1 OR commodityid=in_commodityid2)) IS NOT NULL THEN
    UPDATE serialdailydata_t
         SET contractmonth=v_contractmonth,
             pricegap=v_pricegap
         WHERE currentdate=v_currentdate AND (commodityid=in_commodityid1 OR commodityid=in_commodityid2);
  ELSE
   IF(LEFT(v_contractmonth,2)=in_commodityid2) THEN
    INSERT serialdailydata_t(contractmonth, currentdate, commodityid, pricegap)
         VALUES(v_contractmonth, v_currentdate, in_commodityid2, v_pricegap);
	ELSE
    INSERT serialdailydata_t(contractmonth, currentdate, commodityid, pricegap)
         VALUES(v_contractmonth, v_currentdate, in_commodityid1, v_pricegap);
   END IF;
  END IF;
  
  FETCH NEXT FROM cur_serialcontract INTO v_currentcontractmonth, v_currentdate, v_currentcloseprice;
END WHILE;


CLOSE cur_serialcontract;


UPDATE serialdailydata_t SET
      serialdailydata_t.pricegap=v_pricegap-pricegap
      WHERE (serialdailydata_t.commodityid=in_commodityid1 OR serialdailydata_t.commodityid=in_commodityid2);
      
UPDATE serialdailydata_t, temprawdata_tmp_t SET
      serialdailydata_t.openprice=temprawdata_tmp_t.openprice-pricegap,
      serialdailydata_t.highprice=temprawdata_tmp_t.highprice-pricegap,
      serialdailydata_t.lowprice=temprawdata_tmp_t.lowprice-pricegap,
      serialdailydata_t.closeprice=temprawdata_tmp_t.closeprice-pricegap,
      serialdailydata_t.volume=temprawdata_tmp_t.volume,
      serialdailydata_t.openinterest=temprawdata_tmp_t.openinterest
      WHERE (serialdailydata_t.commodityid=in_commodityid1 OR serialdailydata_t.commodityid=in_commodityid2)
            AND serialdailydata_t.contractmonth=temprawdata_tmp_t.contractid
            AND serialdailydata_t.currentdate=temprawdata_tmp_t.currentdate;
           
DROP TABLE IF EXISTS temprawdata_tmp_t;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updateserialcotract_p`
--

DROP PROCEDURE IF EXISTS `updateserialcotract_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateserialcotract_p`()
top:BEGIN

DECLARE v_commodityid VARCHAR(4);
DECLARE v_contractmonth VARCHAR(10);
DECLARE v_currentcontractmonth VARCHAR(10);
DECLARE v_previouscontractmonth VARCHAR(10);
DECLARE v_counter INT DEFAULT 0;
DECLARE v_closepricegap DOUBLE;
DECLARE v_done BOOL DEFAULT false;
DECLARE cur_todaymastercontract CURSOR FOR SELECT commodityid, contractid FROM(SELECT contract_t.commodityid, marketdaydata_t.contractid,
          marketdaydata_t.currentdate, marketdaydata_t.openprice,marketdaydata_t.highprice,
          marketdaydata_t.lowprice,marketdaydata_t.closeprice,
          marketdaydata_t.volume,marketdaydata_t.openinterest FROM marketdaydata_t, contract_t where
          contract_t.contractid=marketdaydata_t.contractid
          AND currentdate=CURRENT_DATE ORDER BY volume DESC) mct
          GROUP BY mct.commodityid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;


IF IFNULL((SELECT isworkday FROM exchangecalendar_t WHERE everydate=CURRENT_DATE),0)<>1 THEN
  LEAVE top;
END IF;


INSERT serialdailydata_t
SELECT cm_t.commodityid,md_t.contractid,md_t.currentdate,md_t.openprice,md_t.highprice,md_t.lowprice,
md_t.closeprice,md_t.volume,md_t.openinterest,0
FROM commodity_t AS cm_t, marketdaydata_t AS md_t
WHERE md_t.contractid=cm_t.mastercontractid
AND md_t.currentdate=CURRENT_DATE;

OPEN cur_todaymastercontract;
FETCH cur_todaymastercontract INTO v_commodityid, v_currentcontractmonth;
WHILE NOT v_done DO
  SET v_counter=(SELECT newmastercounter FROM commodity_t WHERE commodityid=v_commodityid);
  SET v_previouscontractmonth=(SELECT newmastercontractid FROM commodity_t WHERE commodityid=v_commodityid);
  SET v_contractmonth=(SELECT mastercontractid FROM commodity_t WHERE commodityid=v_commodityid);
  
  
   
  IF(v_counter>0) THEN
    SET v_counter=v_counter+1;
    IF(v_counter>=5) THEN
      
      SET v_closepricegap=(SELECT after_t.closeprice-before_t.closeprice 
           FROM marketdaydata_t as before_t,marketdaydata_t as after_t  
           WHERE before_t.contractid=v_contractmonth 
           AND after_t.contractid=v_previouscontractmonth
           AND after_t.currentdate=before_t.currentdate
           AND before_t.currentdate<=CURRENT_DATE
           AND after_t.currentdate<=CURRENT_DATE
           ORDER BY before_t.currentdate DESC
           LIMIT 0,1);
      SET v_contractmonth=v_previouscontractmonth;
      SET v_counter=0; 
      IF(v_previouscontractmonth<>v_currentcontractmonth) THEN
        SET v_counter=1;
      END IF;
            
      UPDATE serialdailydata_t SET
            openprice=openprice-v_closepricegap,
            highprice=highprice-v_closepricegap,
            lowprice=lowprice-v_closepricegap,
            closeprice=closeprice-v_closepricegap,
            volume=volume,
            openinterest=openinterest,
            pricegap=pricegap-v_closepricegap
            WHERE commodityid=v_commodityid;                             
    ELSEIF(v_previouscontractmonth<>v_currentcontractmonth) THEN
      SET v_counter=1;
    ELSEIF(v_currentcontractmonth=v_contractmonth) THEN
      SET v_counter=0;  
    END IF;
  ELSE
    
    IF(v_previouscontractmonth<>v_currentcontractmonth) THEN
      SET v_counter=1;
    END IF;         
  END IF;
  
  
  UPDATE commodity_t SET
  mastercontractid=v_contractmonth, 
  newmastercontractid=v_currentcontractmonth, 
  newmastercounter=v_counter
  WHERE commodityid=v_commodityid;
  
  
  FETCH NEXT FROM cur_todaymastercontract INTO v_commodityid, v_currentcontractmonth; 
END WHILE;
CLOSE cur_todaymastercontract;

END top $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

--
-- Definition of procedure `updateusercommodity_p`
--

DROP PROCEDURE IF EXISTS `updateusercommodity_p`;

DELIMITER $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateusercommodity_p`(in commodityid2 VARCHAR(4))
BEGIN

DECLARE v_commodityid VARCHAR(4);
DECLARE v_userid VARCHAR(20);
DECLARE v_tradechargetype INT(11);
DECLARE v_tradecharge FLOAT;
DECLARE v_deliverchargebyunit FLOAT;
DECLARE v_deliverchargebyhand FLOAT;
DECLARE v_futuretocurrenchargebyunit FLOAT;
DECLARE v_futuretocurrenchargebyhand FLOAT;
DECLARE v_lendrate FLOAT;
DECLARE v_trademargingap FLOAT;
DECLARE v_id INT(11);
DECLARE done INT DEFAULT 0;
DECLARE cur_user CURSOR FOR SELECT DISTINCT userid FROM usercommodity_t ORDER BY userid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN cur_user;
FETCH cur_user INTO v_userid;
REPEAT
   SELECT commodityid,tradechargetype,tradecharge,deliverchargebyunit,deliverchargebyhand,futuretocurrenchargebyunit,futuretocurrenchargebyhand,trademargingap
    INTO v_commodityid,v_tradechargetype,v_tradecharge,v_deliverchargebyunit,v_deliverchargebyhand,v_futuretocurrenchargebyunit,v_futuretocurrenchargebyhand,v_trademargingap
    FROM ibbranchcommodity_t  WHERE commodityid=commodityid2;

   IF v_userid='lili' THEN
     SET v_lendrate=0.71;
   ELSE
     SET v_lendrate=0.065;
   END IF;

   INSERT INTO usercommodity_t VALUES(v_commodityid,v_userid,v_tradechargetype,v_tradecharge,v_deliverchargebyunit,v_deliverchargebyhand,v_futuretocurrenchargebyunit,v_futuretocurrenchargebyhand,v_lendrate,v_trademargingap,0);

 FETCH NEXT FROM cur_user INTO v_userid;
UNTIL done=1 END REPEAT;
CLOSE cur_user;

END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
