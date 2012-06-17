DELIMITER $$

DROP PROCEDURE IF EXISTS `futuretest`.`updateserialcotractfromhistory_p`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE  `futuretest`.`updateserialcotractfromhistory_p`(
IN in_commodityid VARCHAR(4)
)
BEGIN
/*declare vars*/
DECLARE v_contractmonth VARCHAR(10);
DECLARE v_currentcontractmonth VARCHAR(10);
DECLARE v_previouscontractmonth VARCHAR(10);
DECLARE v_currentcloseprice DOUBLE DEFAULT 0;
DECLARE v_pricegap DOUBLE DEFAULT 0;/**/
DECLARE v_currentdate DATE;
DECLARE v_exchangeid VARCHAR(10);
DECLARE v_volume BIGINT;
DECLARE v_closepricegap DOUBLE;
DECLARE v_counter INT DEFAULT 0;
DECLARE v_done BOOL DEFAULT false;
DECLARE cur_serialcontract CURSOR FOR SELECT contractid, currentdate, closeprice FROM
       (SELECT contractid, currentdate, closeprice, commodityid FROM marketdaydata_t sub
              WHERE commodityid=in_commodityid  ORDER BY sub.currentdate, sub.volume DESC ) mst
        GROUP BY mst.currentdate;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

/*get the today valid last records*/
DROP TABLE IF EXISTS temprawdata_tmp_t;
CREATE TEMPORARY TABLE  temprawdata_tmp_t select * from marketdaydata_t
WHERE commodityid=in_commodityid;

-- delete from serialdailydata_t;
/*open cursor*/
OPEN cur_serialcontract;
FETCH cur_serialcontract INTO v_currentcontractmonth, v_currentdate, v_currentcloseprice;
SET v_contractmonth=v_currentcontractmonth;
SET v_previouscontractmonth=v_currentcontractmonth;
SET v_pricegap=0;
WHILE NOT v_done DO
  /* if is deliver month*/
  IF ((RIGHT(v_currentcontractmonth,2)=MONTH(v_currentdate))
      &&(LEFT(RIGHT(v_contractmonth,3),1)=MOD(YEAR(v_currentdate),10))) THEN
    -- IF (RIGHT(v_currentcontractmonth,2)=MONTH(v_currentdate)) THEN
      SET v_currentcontractmonth=(SELECT contractid from temprawdata_tmp_t where
                         currentdate=v_currentdate and contractid<>v_currentcontractmonth order by volume DESC LIMIT 0,1 );
    --   SET v_contractmonth=v_currentcontractmonth;
    -- END IF;
    SET v_contractmonth=v_currentcontractmonth;
    SET v_previouscontractmonth=v_currentcontractmonth;
    SET v_counter=0;
  END IF;
  /*check the master contract could be changed*/
  IF(v_counter>0) THEN
    /*check if the new contract continue being master contract 5 times*/
    IF(v_counter>=5) THEN
      /* must be one same day*/
      SET v_closepricegap=(SELECT after_t.closeprice-before_t.closeprice
           FROM temprawdata_tmp_t as before_t,marketdaydata_t as after_t
           WHERE before_t.contractid=v_contractmonth
           AND after_t.contractid=v_previouscontractmonth
           AND after_t.currentdate=before_t.currentdate
           AND before_t.currentdate<=v_currentdate
           AND after_t.currentdate<=v_currentdate
           ORDER BY before_t.currentdate DESC
           LIMIT 0,1);
      /*compute the pricegap*/
      SET v_pricegap=v_pricegap+v_closepricegap;
      SET v_contractmonth=v_previouscontractmonth;
      SET v_counter=0;
      /*if the 6rd day the master contract changed*/
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
    /*if the master contract changed, record*/
    IF(v_previouscontractmonth<>v_currentcontractmonth) THEN
      SET v_counter=1;
    END IF;
  END IF;
  
  /*record the previous value*/
  SET v_previouscontractmonth=v_currentcontractmonth;
  IF(SELECT currentdate FROM serialdailydata_t WHERE currentdate=v_currentdate
            AND commodityid=in_commodityid) IS NOT NULL THEN
    UPDATE serialdailydata_t
         SET contractmonth=v_contractmonth,
             pricegap=v_pricegap
         WHERE currentdate=v_currentdate AND commodityid=in_commodityid;
  ELSE
    INSERT serialdailydata_t(contractmonth, currentdate, commodityid, pricegap)
         VALUES(v_contractmonth, v_currentdate, in_commodityid, v_pricegap);
  END IF;
  /*move next*/
  FETCH NEXT FROM cur_serialcontract INTO v_currentcontractmonth, v_currentdate, v_currentcloseprice;
END WHILE;

/*close the cursor*/
CLOSE cur_serialcontract;

/*update the pricegap*/
UPDATE serialdailydata_t SET
      serialdailydata_t.pricegap=v_pricegap-pricegap
      WHERE serialdailydata_t.commodityid=in_commodityid;
/*update the price info*/      
UPDATE serialdailydata_t, temprawdata_tmp_t SET
      serialdailydata_t.openprice=temprawdata_tmp_t.openprice-pricegap,
      serialdailydata_t.highprice=temprawdata_tmp_t.highprice-pricegap,
      serialdailydata_t.lowprice=temprawdata_tmp_t.lowprice-pricegap,
      serialdailydata_t.closeprice=temprawdata_tmp_t.closeprice-pricegap,
      serialdailydata_t.volume=temprawdata_tmp_t.volume,
      serialdailydata_t.openinterest=temprawdata_tmp_t.openinterest
      WHERE serialdailydata_t.commodityid=in_commodityid
            AND serialdailydata_t.contractmonth=temprawdata_tmp_t.contractid
            AND serialdailydata_t.currentdate=temprawdata_tmp_t.currentdate;
           
DROP TABLE IF EXISTS temprawdata_tmp_t;
END $$

DELIMITER ;