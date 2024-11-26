-- �ǹ��� ������ ��뷮
create table ADDR_DATA 
as
SELECT LOTNO_ADDR, ROAD_NM_ADDR, SGNG_CD, STDG_CD,
       STNDD_YR, USE_MM, 
       ELRW_USQNT, CTY_GAS_USQNT, SUM_NRG_USQNT,
       ROUND(ELRW_GRGS_DSAMT) as ELRW_GRGS_DSAMT, 
       ROUND(CTY_GAS_GRGS_DSAMT) as CTY_GAS_GRGS_DSAMT, 
       ROUND(SUM_GRGS_DSAMT) as SUM_GRGS_DSAMT
FROM daejeon_energy1
ORDER BY STNDD_YR, TO_NUMBER(USE_MM);

SELECT RPAD(' ', 4) || 'private ' ||
   CASE
   WHEN A.DATA_TYPE = 'VARCHAR2' THEN 'String'
   WHEN A.DATA_TYPE = 'NUMBER' THEN 'int'
   WHEN A.DATA_TYPE = 'FLOAT' THEN 'Float'
   WHEN A.DATA_TYPE = 'CHAR' AND A.DATA_LENGTH > 1 THEN 'String'
   WHEN A.DATA_TYPE = 'DATE' THEN 'String'
   ELSE 'Object'
   END ||
   ' ' ||
   CONCAT
   (
    LOWER(SUBSTR(B.COLUMN_NAME, 1, 1)),
    SUBSTR(REGEXP_REPLACE(INITCAP(B.COLUMN_NAME), ' |_'), 2)
   ) || CHR(59) || CHR(13) as alis
FROM   ALL_TAB_COLUMNS A
     , ALL_COL_COMMENTS B
WHERE  A.TABLE_NAME = B.TABLE_NAME
AND    A.COLUMN_NAME = B.COLUMN_NAME
AND    A.OWNER = 'TEAM1'
AND    B.OWNER = 'TEAM1'
AND    A.TABLE_NAME = 'ADDR_DATA'
ORDER BY A.COLUMN_ID;

-- �ش� �ǹ��� �����ִ� ������ �⵵
SELECT distinct STNDD_YR
FROM addr_data
WHERE ROAD_NM_ADDR = '���������� ���� ������ 73'
OR LOTNO_ADDR = '���������� ���� �л굿 1389����' -- ���� ���� ��ȣ��ȸ��
ORDER BY STNDD_YR;

-- �ǹ� �˻�
SELECT distinct LOTNO_ADDR, ROAD_NM_ADDR, sgng_cd, stdg_cd
FROM addr_data
WHERE ROAD_NM_ADDR LIKE '%������%'
OR LOTNO_ADDR LIKE '%������%';

-- �ش� �ǹ��� ������ 
SELECT LOTNO_ADDR, ROAD_NM_ADDR, SGNG_CD, STDG_CD,
       STNDD_YR, USE_MM, 
       ELRW_USQNT, CTY_GAS_USQNT, SUM_NRG_USQNT,
       ROUND(ELRW_GRGS_DSAMT) as ELRW_GRGS_DSAMT, 
       ROUND(CTY_GAS_GRGS_DSAMT) as CTY_GAS_GRGS_DSAMT, 
       ROUND(SUM_GRGS_DSAMT) as SUM_GRGS_DSAMT
FROM daejeon_energy1
WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����'
AND STNDD_YR = '2022'
ORDER BY STNDD_YR, TO_NUMBER(USE_MM);

-- �ش� �ǹ��� �� ��� �ǹ� ������
SELECT
    STNDD_YR,
    USE_MM,
    SGNG_CD,
    STDG_CD,
    CEIL(AVG(ELRW_USQNT)) as ELRW_USQNT_gu_avg,  
    CEIL(AVG(CTY_GAS_USQNT)) as CTY_GAS_USQNT_gu_avg,
    CEIL(AVG(SUM_NRG_USQNT)) as SUM_NRG_USQNT_gu_avg 
FROM(
        SELECT 
            STNDD_YR,
            USE_MM,
            a.SGNG_CD,
            a.STDG_CD,
            LOTNO_ADDR,
            ROUND(SUM(ELRW_USQNT)) as ELRW_USQNT,  
            ROUND(SUM(CTY_GAS_USQNT)) as CTY_GAS_USQNT,
            ROUND(SUM(SUM_NRG_USQNT)) as SUM_NRG_USQNT 
        FROM daejeon_energy1 a
        WHERE STNDD_YR = '2022'
        AND a.SGNG_CD = (SELECT distinct SGNG_CD
                            FROM daejeon_energy1
                            WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����')
        AND a.STDG_CD = (SELECT distinct STDG_CD
                            FROM daejeon_energy1
                            WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����')
        GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, a.STDG_CD, LOTNO_ADDR
        ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
        )
GROUP BY STNDD_YR, USE_MM, SGNG_CD, STDG_CD
ORDER BY STNDD_YR, TO_NUMBER(USE_MM);

-- �ش�ǹ� ������ + �� ��� �ǹ� ������
SELECT 
        bbb.STNDD_YR,
        bbb.USE_MM,
        bbb.SGNG_CD,
        bbb.STDG_CD,
        aaa.STDG_NM,
        bbb.LOTNO_ADDR, bbb.ROAD_NM_ADDR,
        ELRW_USQNT_avg,
        ELRW_USQNT,
        CTY_GAS_USQNT_avg,
        CTY_GAS_USQNT,
        SUM_NRG_USQNT_avg,
        SUM_NRG_USQNT,
        ELRW_GRGS_DSAMT_avg,
        ELRW_GRGS_DSAMT,
        CTY_GAS_GRGS_DSAMT_avg,
        CTY_GAS_GRGS_DSAMT,
        SUM_GRGS_DSAMT_avg,
        SUM_GRGS_DSAMT
FROM(
            SELECT
                STNDD_YR,
                USE_MM,
                aa.SGNG_CD,
                aa.STDG_CD,
                bb.STDG_NM,
                CEIL(AVG(ELRW_USQNT)) as ELRW_USQNT_avg,  
                CEIL(AVG(CTY_GAS_USQNT)) as CTY_GAS_USQNT_avg,
                CEIL(AVG(SUM_NRG_USQNT)) as SUM_NRG_USQNT_avg,
                CEIL(AVG(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT_avg,  
                CEIL(AVG(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT_avg,
                CEIL(AVG(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT_avg 
            FROM(
                    SELECT 
                        STNDD_YR,
                        USE_MM,
                        a.SGNG_CD,
                        a.STDG_CD,
                        LOTNO_ADDR,
                        ROUND(SUM(ELRW_USQNT)) as ELRW_USQNT,  
                        ROUND(SUM(CTY_GAS_USQNT)) as CTY_GAS_USQNT,
                        ROUND(SUM(SUM_NRG_USQNT)) as SUM_NRG_USQNT,
                        ROUND(SUM(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT, 
                        ROUND(SUM(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT, 
                        ROUND(SUM(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT
                    FROM daejeon_energy1 a
                    WHERE STNDD_YR = '2022'
                    AND a.SGNG_CD = (SELECT distinct SGNG_CD
                                        FROM daejeon_energy1
                                        WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����')
                    AND a.STDG_CD = (SELECT distinct STDG_CD
                                        FROM daejeon_energy1
                                        WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����')
                    GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, a.STDG_CD, LOTNO_ADDR
                    ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
                    ) aa, sgng_stdg_nm bb
            WHERE aa.sgng_cd = bb.sgng_cd
            AND aa.stdg_cd = bb.stdg_cd
            GROUP BY STNDD_YR, USE_MM, aa.SGNG_CD, aa.STDG_CD, bb.STDG_NM
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM)
            ) aaa, (
               SELECT LOTNO_ADDR, ROAD_NM_ADDR, SGNG_CD, STDG_CD,
                       STNDD_YR, USE_MM, 
                       ELRW_USQNT, CTY_GAS_USQNT, SUM_NRG_USQNT,
                       ROUND(ELRW_GRGS_DSAMT) as ELRW_GRGS_DSAMT, 
                       ROUND(CTY_GAS_GRGS_DSAMT) as CTY_GAS_GRGS_DSAMT, 
                       ROUND(SUM_GRGS_DSAMT) as SUM_GRGS_DSAMT
                FROM daejeon_energy1
                WHERE LOTNO_ADDR = '���������� ���� �л굿 1389����'
                AND STNDD_YR = '2022'
                ORDER BY STNDD_YR, TO_NUMBER(USE_MM)) bbb
WHERE aaa.use_mm=bbb.use_mm
AND aaa.STDG_CD = bbb.STDG_CD;

-- �ǹ��뵵 -> ���� ������ �������� ��ȯ
SELECT substr(stdg_cd,1,5) as SGNG_CD, 
       substr(stdg_cd,6,5) as stdg_cd, 
       stdg_nm || ' ' || lotno_no || '����' as LOTNO_ADDR, 
       mjr_prps_cd, mjr_prps_nm
FROM building_usage
WHERE substr(stdg_cd,1,5)='30230';

-- �ǹ��뵵 join ���� ������
SELECT a.mjr_prps_cd, a.mjr_prps_nm,
       b.* 
FROM building_usage1 a, daejeon_energy1 b
WHERE a.lotno_addr = b.lotno_addr;

-- �ǹ��뵵 
SELECT distinct mjr_prps_cd, mjr_prps_nm
FROM building_usage1;