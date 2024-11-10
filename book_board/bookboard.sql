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

SELECT user_pw FROM tb_user WHERE user_id = 'admin';

INSERT INTO tb_user(user_id, user_pw, user_nm)
VALUES ('admin', 'admin', 'admin');


UPDATE tb_user SET user_nm='관리자' WHERE user_id='admin';

commit;

UPDATE tb_user 
SET user_nm=:2
  , user_email=:3 
  WHERE user_id=:1;
  

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
    ,b_isbn VARCHAR2(100) PRIMARY KEY
    ,b_page NUMBER
    ,b_category VARCHAR2(100) 
    ,b_memo VARCHAR2(1000) 
    ,b_end_yn VARCHAR2(1) DEFAULT 'N'
    ,b_create_dt DATE
    ,b_update_dt DATE
);
ALTER TABLE tb_book ADD CONSTRAINT fk_book 
FOREIGN KEY(user_id) REFERENCES tb_user (user_id);
--DROP TABLE tb_book;
SELECT * FROM tb_book;

INSERT INTO tb_book(user_id, b_title, b_author, b_dicount
                    ,b_isbn, b_page, b_category, b_memo)
VALUES ('aaaa', '방금 떠나온 세계', '김초엽', 10500, 
        '9791160406504', 323, '800', '소설');

--UPDATE tb_book SET b_category=800 WHERE b_isbn='9791160406504';

SELECT b_end_yn, b_title, b_author, 
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
        b_page, b_dicount, 
        NVL(TO_CHAR(b_create_dt, 'YYYY-MM-DD'),' ') as b_create_dt, 
        NVL(TO_CHAR(b_update_dt, 'YYYY-MM-DD'),' ') as b_update_dt
FROM tb_book
WHERE user_id='aaaa';

SELECT b_title, b_author, b_isbn
FROM tb_book
WHERE user_id = 'aaaa';


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
FOREIGN KEY(user_id) REFERENCES tb_user (user_id);
ALTER TABLE tb_bookRecord ADD CONSTRAINT fk2_bookRecord 
FOREIGN KEY(b_isbn) REFERENCES tb_book (b_isbn);

SELECT * FROM tb_bookrecord;

INSERT INTO tb_bookrecord(user_id, b_isbn, r_date, r_page)
VALUES('aaaa', '9791160406504', TO_DATE('2024-11-10', 'YYYY-MM-DD'), 30);

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
AND a.user_id = 'aaaa';

commit;
