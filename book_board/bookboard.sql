-- 계정 생성 (DBA 권한 있는 계정에서 실행)
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
CREATE USER book IDENTIFIED BY book;
GRANT CONNECT, RESOURCE TO book;
GRANT UNLIMITED TABLESPACE to book;

/*
    회원 테이블
    ID, PW, email, 활성화여부, 등록일자, 수정일자
*/
CREATE TABLE tb_user (
     user_id VARCHAR2(100) PRIMARY KEY
    ,user_pw VARCHAR2(100) NOT NULL
    ,user_nm VARCHAR2(100) NOT NULL
    ,user_email VARCHAR2(100) 
    ,use_yn VARCHAR2(1) DEFAULT 'Y'
    ,update_dt DATE DEFAULT SYSDATE
    ,create_dt DATE DEFAULT SYSDATE
);
--DROP TABLE tb_user;
SELECT * FROM tb_user;
 

/*
    목표 도서 테이블
    user_id(fk),
    제목, 작가, 가격, isbn(pk), 총 페이지, 카테고리, 메모
    완독여부, 리스트 등록일, 완독일
*/
CREATE TABLE tb_book (
     user_id VARCHAR2(100) 
    ,b_title VARCHAR2(1000)
    ,b_author VARCHAR2(1000)
    ,b_dicount NUMBER 
    ,b_isbn VARCHAR2(100)
    ,b_page NUMBER
    ,b_category VARCHAR2(100) 
    ,b_memo VARCHAR2(1000)
    ,b_mlday VARCHAR2(100)
    ,b_mlpage VARCHAR2(100)
    ,b_image VARCHAR2 (1000)
    ,b_end_yn VARCHAR2(1) DEFAULT 'N'
    ,b_create_dt DATE
    ,b_update_dt DATE
);
ALTER TABLE tb_book ADD CONSTRAINT fk_book 
FOREIGN KEY(user_id) REFERENCES tb_user (user_id);
ALTER TABLE tb_book ADD CONSTRAINT pk_book 
PRIMARY KEY(user_id, b_isbn);

--DROP TABLE tb_book;
SELECT * FROM tb_book;
SELECT * FROM tb_bookrecord;


/*
    독서 기록 테이블
    user_id(fk),
    isbn(fk), 읽은 날짜, 읽은 페이지
*/
CREATE TABLE tb_bookRecord (
     user_id VARCHAR2(100) 
    ,b_isbn VARCHAR2(100)
    ,r_date DATE
    ,r_page NUMBER
);
--DROP TABLE tb_bookRecord;
ALTER TABLE tb_bookRecord ADD CONSTRAINT fk_bookRecord 
FOREIGN KEY(user_id, b_isbn) REFERENCES tb_book (user_id, b_isbn) ON DELETE CASCADE;

SELECT * FROM tb_book;

DELETE tb_bookrecord WHERE b_isbn='9791170401421';
DELETE tb_book WHERE b_isbn='9791170401421';
commit;
-- 메인화면 : 읽을책
SELECT distinct a.b_title, a.b_author, a.b_isbn, 
     NVL(SUM(b.r_page) OVER(PARTITION BY b.b_isbn), 0) as cur_page,
     a.b_page,
     (a.b_page - NVL(SUM(b.r_page) OVER(PARTITION BY b.b_isbn), 0)) as to_page,
     a.b_create_dt
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn(+)
AND a.user_id = 'aaaa'
AND a.b_end_yn = 'N'
ORDER BY a.b_create_dt;

SELECT distinct a.b_title, a.b_author, a.b_isbn, 
     NVL(SUM(b.r_page) OVER(PARTITION BY b.b_isbn), 0) as cur_page,
     a.b_page,
    (a.b_page - NVL(SUM(b.r_page) OVER(PARTITION BY b.b_isbn), 0)) as to_page,
     a.b_create_dt
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn(+)
AND a.user_id = b.user_id(+)
AND a.user_id = 'lsh111'
AND a.b_end_yn = 'N'
ORDER BY a.b_create_dt DESC;

-- 읽을 책 조회
SELECT  distinct
        CASE WHEN b_create_dt IS NULL THEN 'N'
             ELSE 'Y'
        END as read_yn
        , b_title, b_author,  
        CASE WHEN b_category = '000' THEN '총류, 컴퓨터과학'
             WHEN b_category = '100' THEN '철학, 심리학, 윤리학'
             WHEN b_category = '200' THEN '종교'
             WHEN b_category = '300' THEN '사회과학'
             WHEN b_category = '400' THEN '어학'
             WHEN b_category = '500' THEN '순수과학'
             WHEN b_category = '600' THEN '기술과학'
             WHEN b_category = '700' THEN '예술'
             WHEN b_category = '800' THEN '문학'
             WHEN b_category = '900' THEN '역사'
             ELSE '기타'
        END as b_category, 
        NVL(b_memo, ' '),
        b_page, 
        NVL(SUM(b.r_page) OVER(PARTITION BY b.b_isbn), 0) as cur_page, 
        NVL(TO_CHAR(b_create_dt, 'YYYY-MM-DD'),' ') as b_create_dt, 
        NVL(TO_CHAR(b_update_dt, 'YYYY-MM-DD'),' ') as b_update_dt,
        a.b_isbn
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn(+)
AND a.user_id = b.user_id(+)
AND a.user_id= 'lsh111'
AND b_end_yn = 'N'
ORDER BY b_create_dt DESC;

SELECT b_title, b_create_dt
FROM tb_book
WHERE user_id = 'lsh111';

--상세 기록 조회
SELECT b.b_title, b.b_author
     , TO_CHAR(a.r_date, 'YYYY-MM-DD') as r_date
     , a.r_page
     , SUM(a.r_page) OVER(PARTITION BY a.b_isbn
                            ORDER BY a.r_date
                            ROWS BETWEEN UNBOUNDED PRECEDING 
                                    AND CURRENT ROW) as sum_page
     , b.b_page
FROM tb_bookrecord a, tb_book b
WHERE a.b_isbn = b.b_isbn
AND a.user_id = 'aaaa'
ORDER BY b.b_create_dt, a.r_date;

-- 상세 기록 삭제
DELETE tb_bookrecord
WHERE b_isbn = '9791170401421' 
AND r_date = TO_DATE('2024-10-30','YYYY-MM-DD');

-- 기록 삭제시 기간 조정
SELECT *
FROM tb_book
WHERE b_isbn = '9791170401421' 
AND user_id='aaaa';

UPDATE tb_book a
SET (a.b_create_dt, a.b_update_dt) = (
                                        SELECT distinct MIN(r_date) OVER(PARTITION BY b.b_isbn)
                                              ,MAX(r_date) OVER(PARTITION BY b.b_isbn)
                                        FROM tb_bookrecord b
                                        WHERE b.b_isbn(+) = a.b_isbn
                                        AND a.user_id = b.user_id(+)
                                        AND  b.r_date IS NOT NULL
                                        )
WHERE a.user_id='lsh111';

SELECT * FROM tb_book WHERE user_id='lsh111';

SELECT distinct MIN(r_date) OVER(PARTITION BY b.b_isbn)
              ,MAX(r_date) OVER(PARTITION BY b.b_isbn)
        FROM tb_bookrecord b, tb_book a
        WHERE b.b_isbn(+) = a.b_isbn
        AND a.user_id = b.user_id(+)
        AND a.user_id='lsh111'
        AND  b.r_date IS NOT NULL;

commit;
rollback;

SELECT count(*)
FROM tb_bookrecord;

SELECT count(*)
FROM tb_book;

-- 목표도서 삭제
DELETE tb_book
WHERE user_id='aaaa'
AND b_isbn='9791141601447';

-- 도서별 상세기록
SELECT a.b_title, a.b_author 
      ,b.r_date, b.r_page
      ,SUM(r_page) OVER(
                        ORDER BY r_date
                        ROWS BETWEEN UNBOUNDED PRECEDING 
                                    AND CURRENT ROW) as page
      ,a.b_page
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn
AND a.user_id = 'aaaa'
ORDER BY a.b_create_dt DESC, b.r_date;

-- 다 읽은 책 완독여부 update
UPDATE tb_book a
SET a.b_end_yn = 'Y'
WHERE (a.b_isbn, a.b_page) IN (
                                SELECT b.b_isbn, SUM(b.r_page) OVER(PARTITION BY b.b_isbn)
                                FROM tb_bookrecord b
                                WHERE b.b_isbn = a.b_isbn
                                )
AND a.user_id='aaaa';

---기간 업데이트
UPDATE tb_book a
SET (a.b_create_dt, a.b_update_dt) = (
                                        SELECT distinct NVL(MIN(r_date) OVER(PARTITION BY b_isbn),null)
                                              ,NVL(MAX(r_date) OVER(PARTITION BY b_isbn),null)
                                        FROM tb_bookrecord b
                                        WHERE b.b_isbn(+) = a.b_isbn
                                        AND a.user_id = b.user_id(+)
                                        )
WHERE a.user_id='aaaa';
commit;

SELECT distinct b_title, b_create_dt, b_update_dt
FROM tb_bookrecord b, tb_book a
WHERE b.user_id='lsh111'
AND a.b_isbn = b.b_isbn(+);

commit;

SELECT *
FROM tb_book
WHERE user_id='lsh111';

--다 읽은 책 조회
SELECT distinct b.b_title, b.b_isbn, b.b_author, b.b_page
     , TO_CHAR(b.b_create_dt, 'YYYY-MM-DD') as b_create_dt
     , TO_CHAR(b.b_update_dt, 'YYYY-MM-DD') as b_update_dt
     ,CASE WHEN b.b_category = '000' THEN '총류, 컴퓨터과학'
             WHEN b.b_category = '100' THEN '철학, 심리학, 윤리학'
             WHEN b.b_category = '200' THEN '종교'
             WHEN b.b_category = '300' THEN '사회과학'
             WHEN b.b_category = '400' THEN '어학'
             WHEN b.b_category = '500' THEN '순수과학'
             WHEN b.b_category = '600' THEN '기술과학'
             WHEN b.b_category = '700' THEN '예술'
             WHEN b.b_category = '800' THEN '문학'
             WHEN b.b_category = '900' THEN '역사'
             ELSE '기타'
        END as b_category
     , b.b_memo
     , b.b_dicount
     , COUNT(a.r_date) OVER(PARTITION BY b.b_isbn) as day
     , MAX(a.r_page) OVER(PARTITION BY b.b_isbn) as maxpage
     , MIN(a.r_page) OVER(PARTITION BY b.b_isbn) as minpage
FROM tb_bookrecord a, tb_book b, tb_user c
WHERE a.b_isbn = b.b_isbn
AND a.user_id = c.user_id
AND b.b_end_yn = 'Y'
AND c.user_id='aaaa'
ORDER BY b_create_dt DESC;

-- 메인화면 : 올해 책에 쓴 돈
SELECT sum(b_dicount) as yrmoney
FROM tb_book
WHERE user_id='aaaa';

-- 메인화면 : 읽은 페이지, 읽은 날, 읽은 책 권수
SELECT sum(b.r_page) as yrpage
      ,count(distinct a.b_isbn) as yrbook
      ,count(distinct r_date) as yrdt
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn(+) 
AND a.user_id = b.user_id(+)
AND b.b_isbn IS NOT NULL
AND b.user_id='lsh111';

-- 메인화면 : 마지막으로 읽은 날, 읽은 책
SELECT TO_CHAR(b_update_dt, 'YYYYMMDD') as lastday
     , b_title as lastbook
FROM tb_book
WHERE b_update_dt = (
                        SELECT MAX(b_update_dt)
                        FROM tb_book
                        WHERE user_id='lsh111');
SELECT *
FROM tb_book
WHERE user_id='lsh111';

-- 독서 장르
SELECT CASE b_category WHEN '000' THEN '총류, 컴퓨터과학'
                     WHEN '100' THEN '철학, 심리학, 윤리학'
                     WHEN '200' THEN '종교'
                     WHEN '300' THEN '사회과학'
                     WHEN '400' THEN '어학'
                     WHEN '500' THEN '순수과학'
                     WHEN '600' THEN '기술과학'
                     WHEN '700' THEN '예술'
                     WHEN '800' THEN '문학'
                     WHEN '900' THEN '역사'
                     ELSE '기타'
                     END as b_category
      ,COUNT(b_category) as cnt
FROM tb_book
GROUP BY b_category;

-- 데이터 생성
INSERT INTO tb_book(user_id, b_title, b_author, b_dicount, b_isbn, b_page, b_category)
SELECT 'ml11', a.b_title, a.b_author, a.b_dicount, a.b_isbn||'61', a.b_page-1, a.b_category
FROM tb_book a
WHERE user_id='ml12';

INSERT INTO tb_bookrecord(user_id, b_isbn, r_date, r_page)
SELECT 'ml11', a.b_isbn||'61', r_date-1, r_page-1
FROM tb_bookrecord a
WHERE user_id='ml12';


commit;

SELECT *
FROM tb_user;

SELECT *
FROM tb_bookrecord
WHERE user_id='lsh111';



SELECT count(*)
FROM tb_bookrecord;

-- 페이지 그래프
SELECT TO_CHAR(r_date, 'YYYYMMDD') as dt
      ,SUM(r_page) OVER(
                        ORDER BY r_date
                        ROWS BETWEEN UNBOUNDED PRECEDING 
                                    AND CURRENT ROW) as page
FROM tb_bookrecord
WHERE user_id = 'aaaa';

SELECT SUBSTR(dt, 5,2) || '월' as mon
    , SUM(page) OVER(ORDER BY dt
                        ROWS BETWEEN UNBOUNDED PRECEDING 
                                    AND CURRENT ROW) as page
FROM(
SELECT TO_CHAR(r_date, 'YYYYMM') as dt
      ,SUM(r_page)  as page
FROM tb_bookrecord
WHERE user_id = 'aaaa'
GROUP BY TO_CHAR(r_date, 'YYYYMM')
ORDER BY dt);

SELECT distinct a.b_isbn, a.b_title, a.b_category, a.b_page
      ,count(b.r_date) OVER(PARTITION BY a.b_isbn) as day
FROM tb_book a, tb_bookrecord b
WHERE a.b_isbn = b.b_isbn;


--ml
SELECT a.b_isbn
             , a.b_page
             , a.b_category
             , ROUND(AVG(b.r_page), 2) AS read_speed
             , MIN(b.r_date) AS start_dt
             , MAX(b.r_date) AS end_dt
             , COUNT(*) AS days_since_last_read
        FROM tb_book a
           , tb_bookrecord b
        WHERE a.b_isbn = b.b_isbn
        GROUP BY a.b_isbn
               , a.b_page
               , a.b_category
        ORDER BY start_dt;
        
-- 상세 modal
SELECT distinct b_title, b_author, b_dicount
      ,CASE b_category WHEN '000' THEN '총류, 컴퓨터과학'
                     WHEN '100' THEN '철학, 심리학, 윤리학'
                     WHEN '200' THEN '종교'
                     WHEN '300' THEN '사회과학'
                     WHEN '400' THEN '어학'
                     WHEN '500' THEN '순수과학'
                     WHEN '600' THEN '기술과학'
                     WHEN '700' THEN '예술'
                     WHEN '800' THEN '문학'
                     WHEN '900' THEN '역사'
                     ELSE '기타'
                     END as b_category
      ,NVL(b_memo,' ') as b_memo
      ,NVL(b_mlday, ' ') as b_mlday
      ,NVL(b_mlpage, ' ') as b_mlpage
      ,b_image
      ,TO_CHAR(b_create_dt, 'YYYY-MM-DD') as b_create_dt
      ,TO_CHAR(b_update_dt, 'YYYY-MM-DD') as b_create_dt
      ,COUNT(r_date) OVER(PARTITION BY b.b_isbn) as rlday
      ,ROUND(AVG(r_page) OVER(PARTITION BY b.b_isbn),2) as rlpage
FROM tb_book a, tb_bookrecord b
WHERE a.user_id='lsh111'
AND a.b_isbn = '9791190090018'
AND a.b_isbn = b.b_isbn
AND a.user_id = b.user_id;

commit;
