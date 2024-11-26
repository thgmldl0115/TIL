-- id="getAllData" , ������ ��ü ������ ��� (���� : MWh)
SELECT 
    STNDD_YR,
    USE_MM,
    CEIL(SUM(ELRW_USQNT)/1000) as ELRW_USQNT,  
    CEIL(SUM(CTY_GAS_USQNT)/1000) as CTY_GAS_USQNT,
    CEIL(SUM(SUM_NRG_USQNT)/1000) as SUM_NRG_USQNT
FROM daejeon_energy1
WHERE STNDD_YR = '2022'
GROUP BY STNDD_YR, USE_MM
ORDER BY STNDD_YR, TO_NUMBER(USE_MM);

-- ������ �� ��� / ���� ������ ��뷮
SELECT 
    bb.STNDD_YR,
    bb.USE_MM,
    ELRW_USQNT_avg,
    ELRW_USQNT,
    CTY_GAS_USQNT_avg,
    CTY_GAS_USQNT,
    SUM_NRG_USQNT_avg,
    SUM_NRG_USQNT
FROM (
            SELECT
                STNDD_YR,
                USE_MM,
                CEIL(AVG(ELRW_USQNT)/1000) as ELRW_USQNT_avg,  
                CEIL(AVG(CTY_GAS_USQNT)/1000) as CTY_GAS_USQNT_avg,
                CEIL(AVG(SUM_NRG_USQNT)/1000) as SUM_NRG_USQNT_avg 
            FROM(
                    SELECT 
                        STNDD_YR,
                        USE_MM,
                        a.SGNG_CD,
                        ROUND(SUM(ELRW_USQNT)) as ELRW_USQNT,  
                        ROUND(SUM(CTY_GAS_USQNT)) as CTY_GAS_USQNT,
                        ROUND(SUM(SUM_NRG_USQNT)) as SUM_NRG_USQNT 
                    FROM daejeon_energy1 a
                    WHERE STNDD_YR = '2015'
                    GROUP BY STNDD_YR, USE_MM, a.SGNG_CD
                    ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
                    )
            GROUP BY STNDD_YR, USE_MM
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM)
        ) aa, (
            SELECT 
                STNDD_YR,
                USE_MM,
                a.SGNG_CD,
                CEIL(SUM(ELRW_USQNT)/1000) as ELRW_USQNT,  
                CEIL(SUM(CTY_GAS_USQNT)/1000) as CTY_GAS_USQNT,
                CEIL(SUM(SUM_NRG_USQNT)/1000) as SUM_NRG_USQNT 
            FROM daejeon_energy1 a
            WHERE STNDD_YR = '2015'
            AND a.SGNG_CD = '30170'
            GROUP BY STNDD_YR, USE_MM, a.SGNG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
        ) bb
WHERE aa.USE_MM = bb.USE_MM;
        
-- ������ �� ��� / ���� �½ǰ��� ���ⷮ 
SELECT 
    bb.STNDD_YR,
    bb.USE_MM,
    ELRW_GRGS_DSAMT_avg,
    ELRW_GRGS_DSAMT,
    CTY_GAS_GRGS_DSAMT_avg,
    CTY_GAS_GRGS_DSAMT,
    SUM_GRGS_DSAMT_avg,
    SUM_GRGS_DSAMT
FROM (
            SELECT
                STNDD_YR,
                USE_MM,
                ROUND(AVG(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT_avg,  
                ROUND(AVG(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT_avg,
                ROUND(AVG(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT_avg 
            FROM(
                    SELECT 
                        STNDD_YR,
                        USE_MM,
                        a.SGNG_CD,
                        ROUND(SUM(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT,
                        ROUND(SUM(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT,
                        ROUND(SUM(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT
                    FROM daejeon_energy1 a
                    WHERE STNDD_YR = '2022'
                    GROUP BY STNDD_YR, USE_MM, a.SGNG_CD
                    ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
                    )
            GROUP BY STNDD_YR, USE_MM
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM)
        ) aa, (
            SELECT 
                STNDD_YR,
                USE_MM,
                a.SGNG_CD,
                ROUND(SUM(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT,
                ROUND(SUM(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT,
                ROUND(SUM(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT
            FROM daejeon_energy1 a
            WHERE STNDD_YR = '2022'
            AND a.SGNG_CD = '30170'
            GROUP BY STNDD_YR, USE_MM, a.SGNG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
        ) bb
WHERE aa.USE_MM = bb.USE_MM;

-- ������ �� ��� / ���� ������ ��뷮
SELECT 
    bb.STNDD_YR,
    bb.USE_MM,
    bb.SGNG_CD,
    bb.STDG_CD,
    ELRW_USQNT_gu_avg,
    ELRW_USQNT,
    CTY_GAS_USQNT_gu_avg,
    CTY_GAS_USQNT,
    SUM_NRG_USQNT_gu_avg,
    SUM_NRG_USQNT
FROM (
           SELECT
                STNDD_YR,
                USE_MM,
                SGNG_CD,
                CEIL(AVG(ELRW_USQNT)/1000) as ELRW_USQNT_gu_avg,  
                CEIL(AVG(CTY_GAS_USQNT)/1000) as CTY_GAS_USQNT_gu_avg,
                CEIL(AVG(SUM_NRG_USQNT)/1000) as SUM_NRG_USQNT_gu_avg 
            FROM(
                    SELECT 
                        STNDD_YR,
                        USE_MM,
                        a.SGNG_CD,
                        a.STDG_CD,
                        ROUND(SUM(ELRW_USQNT)) as ELRW_USQNT,  
                        ROUND(SUM(CTY_GAS_USQNT)) as CTY_GAS_USQNT,
                        ROUND(SUM(SUM_NRG_USQNT)) as SUM_NRG_USQNT 
                    FROM daejeon_energy1 a
                    WHERE STNDD_YR = '2022'
                    AND a.SGNG_CD = '30170'
                    GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, a.STDG_CD
                    ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
                    )
            GROUP BY STNDD_YR, USE_MM, SGNG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM)
        ) aa, (
            SELECT 
                STNDD_YR,
                USE_MM,
                a.SGNG_CD,
                STDG_CD,
                CEIL(SUM(ELRW_USQNT)/1000) as ELRW_USQNT,  
                CEIL(SUM(CTY_GAS_USQNT)/1000) as CTY_GAS_USQNT,
                CEIL(SUM(SUM_NRG_USQNT)/1000) as SUM_NRG_USQNT 
            FROM daejeon_energy1 a
            WHERE STNDD_YR = '2022'
            AND a.SGNG_CD = '30170'
            AND a.STDG_CD = '12200'
            GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, STDG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
        ) bb
WHERE aa.USE_MM = bb.USE_MM;

-- ������ �� ��� / ���� �½ǰ��� ���ⷮ
SELECT 
    bb.STNDD_YR,
    bb.USE_MM,
    bb.SGNG_CD,
    bb.STDG_CD,
    ELRW_GRGS_DSAMT_avg,
    ELRW_GRGS_DSAMT,
    CTY_GAS_GRGS_DSAMT_avg,
    CTY_GAS_GRGS_DSAMT,
    SUM_GRGS_DSAMT_avg,
    SUM_GRGS_DSAMT
FROM (
           SELECT
                STNDD_YR,
                USE_MM,
                SGNG_CD,
                ROUND(AVG(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT_avg,  
                ROUND(AVG(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT_avg,
                ROUND(AVG(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT_avg 
            FROM(
                    SELECT 
                        STNDD_YR,
                        USE_MM,
                        a.SGNG_CD,
                        a.STDG_CD,
                        ROUND(SUM(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT,  
                        ROUND(SUM(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT,
                        ROUND(SUM(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT 
                    FROM daejeon_energy1 a
                    WHERE STNDD_YR = '2022'
                    AND a.SGNG_CD = '30170'
                    GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, a.STDG_CD
                    ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
                    )
            GROUP BY STNDD_YR, USE_MM, SGNG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM)
        ) aa, (
            SELECT 
                STNDD_YR,
                USE_MM,
                a.SGNG_CD,
                STDG_CD,
                ROUND(SUM(ELRW_GRGS_DSAMT)) as ELRW_GRGS_DSAMT,
                ROUND(SUM(CTY_GAS_GRGS_DSAMT)) as CTY_GAS_GRGS_DSAMT,
                ROUND(SUM(SUM_GRGS_DSAMT)) as SUM_GRGS_DSAMT
            FROM daejeon_energy1 a
            WHERE STNDD_YR = '2022'
            AND a.SGNG_CD = '30170'
            AND a.STDG_CD = '11200'
            GROUP BY STNDD_YR, USE_MM, a.SGNG_CD, STDG_CD
            ORDER BY STNDD_YR, TO_NUMBER(USE_MM), SGNG_CD
        ) bb
WHERE aa.USE_MM = bb.USE_MM;

-- �ǹ��� ������ ��뷮
SELECT LOTNO_ADDR, ROAD_NM_ADDR, STNDD_YR, USE_MM, ELRW_USQNT, CTY_GAS_USQNT, SUM_NRG_USQNT
FROM daejeon_energy1
WHERE ROAD_NM_ADDR = '���������� ���� ������ 73'
OR LOTNO_ADDR = '���������� ���� �л굿 1389����'
AND STNDD_YR = '2022'
ORDER BY STNDD_YR, TO_NUMBER(USE_MM);

-- �ش� �ǹ��� �����ִ� ������ �⵵
SELECT distinct STNDD_YR
FROM daejeon_energy1
WHERE ROAD_NM_ADDR = '���������� ���� ������ 73'
OR LOTNO_ADDR = '���������� ���� �л굿 1389����' -- ���� ���� ��ȣ��ȸ��
ORDER BY STNDD_YR;

-- �ǹ� �˻�
SELECT distinct LOTNO_ADDR, ROAD_NM_ADDR
FROM daejeon_energy1
WHERE ROAD_NM_ADDR LIKE '%������%'
OR LOTNO_ADDR LIKE '%������%';
