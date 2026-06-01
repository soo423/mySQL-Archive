create database 학사;

create table 학과
	(
		학과번호 char(2)
        ,학과명 varchar(20)
        ,학과장명 varchar(20)
    );
    
insert into 학과 values
	('AA','컴퓨터공학과','배경민')
   ,('BB','소프트웨어학과','김남준')
   ,('CC','디자인융합학과','박선영');
   
create table 학생
	(
		학번 char(5)
        ,이름 varchar(20)
        ,생일 date
        ,연락처 varchar(20)
        ,학과번호 char(2)
    );

insert into 학생 values
	('50001','이윤주','2020-01-30','01033334444','AA')
    ,('50002','이승은','2021-02-23',null,'AA')
    ,('50003','백재용','2018-03-31','01077778888','DD');
    
create table 유학생 as
select *
from 학생
where 1 =2; -- 거짓 조건으로 실제 데이터는 가져오지 않는다.

-- 휘트니스센터의 회원을 관리하는 데이터
create database 헬스케어DB;
use 헬스케어DB;
create table 회원
	(
		아이디 varchar(20) primary key
        ,회원명 varchar(20)
        ,키 int
        ,몸무게 int
        ,체질량지수 decimal(4,1) as (몸무게 / power(키/100, 2)) stored -- 데이터가 입력/수정될 때 계산해서 디스크에 실제로 저장
    );
    
insert into 회원(아이디, 회원명, 키, 몸무게) values
	('APPLE','김사과','178','70');
select * from 회원;

/*alter*/
-- 학생 테이블에 성별 컬럼을 추가
alter table 학생 add 성별 char(1);
-- 컬럼 데이터타입 변경
alter table 학생 modify column 성별 varchar(2);
-- 학생 테이블에서 연락처 컬럼명을 휴대폰번호로 변경
alter table 학생 change column 연락처 휴대폰번호 varchar(20);
-- 학생 테이블에서 성별 컬럼 제거
alter table 학생 drop column 성별;
-- 휴학생 테이블명을 졸업생 테이블명으로 변경
alter table 휴학생 rename 졸업생;

-- 학생 테이블명을 student로 변경
alter table 학생 rename student;
-- 학번 컬럼을 student_id로 변경
alter table student change 학번 student_id varchar(20);
-- student 테이블에 address 컬럼 추가
alter table student add address char(1);
-- address 컬럼의 데이터타입 크기를 50으로 변경
alter table student modify address char(50);
-- address 컬럼 제거
alter table student drop column address;

/*drop : 데이터베이스, 테이블 및 기타 여러 객체를 삭제*/
drop table 학과;
drop table student;

drop database 학사;

/*제약 조건 : 테이블에 잘못된 데이터가 입력되지 않도록 규칙을 정의하는 것, 데이터 무결성(integrity)*/

create database 학사;
use 학사;
create table 학과
	(
		학과번호 char(2) primary key -- 컬럼 레벨의 제약조건
        ,학과명 varchar(2) not null
        ,학과장명 varchar(20)
	);

create table 학과
	(
		학과번호 char(2)
        ,학과명 varchar(20) not null
        ,학과장명 varchar(20)
        ,primary key(학과번호) -- 테이블 레벨로 제약조건 설정
    );
    
create table 학생
(
   학번 char(5) primary key,              -- 기본키
   이름 varchar(20) not null,
   생일 date not null,
   연락처 varchar(20) unique,            -- 유니크 제약조건
   학과번호 char(2),                      -- 외래키 참조할 컬럼
   성별 char(1) check(성별 in ('남','여')),
   등록일 date default (current_date),
   foreign key(학과번호) references 학과(학과번호) -- 외래키
   );
    
create table 과목
	(
		과목번호 char(5) primary key
        ,과목명 varchar(20) not null
        ,학점 int not null check(학점 between 2 and 4)
        ,구분 varchar(20) check(구분 in('전공','교양','일반'))
    );
    
create table 수강_1
    (
		수강년도 char(4) not null
        ,수강학기 varchar(20) not null check(수강학기 in('1학기','2학기','여름학기','겨울학기'))
        ,학번 char(5) not null
        ,과목번호 char(5) not null
        ,primary key(수강년도, 수강학기, 학번, 과목번호)
        ,foreign key(학번) references 학생(학번)
        ,foreign key(과목번호) references 과목(과목번호)
	);
-- 개체 무결성(entity integrity): 기본키(primary key) 컬럼에 중복된 값이 null값이 허용하지 않는 원칙 not null
-- 참조 무결성(referential integrity) : 특정 테이블의 외래키는 다른 테이블의 기본키를 참조함으로써 관계가 항상 일관성 있게 유지되어야함
    
-- 수강번호라는 대리키를 기본키로 하는 제약조건을 추가하여 수강_2 테이블을 생성, 수강번호는 일련번호
create table 수강_2
	(
		-- 대리키 : 일련번호와 같은 컬럼을 생성하는 기본키 사용
        수강번호 int primary key auto_increment -- mysql, 1부터 시작해 자동으로 1씩 증가, auto_increment=1000, 영구결번
        -- ,수강번호 int generated always as identity primary key
        ,수강년도 char(4) not null
        ,수강학기 varchar(20) not null check(수강학기 in('1학기','2학기','여름학기','겨울학기'))
        ,학번 char(5) not null
        ,과목번호 char(5) not null
        ,성적 numeric(3,1) check(성적 between 0 and 4.5)
        ,foreign key(학번) references 학생(학번) -- 외래키
        ,foreign key(과목번호) references 과목(과목번호)
    );
    
-- 데이터의 무결성(잘못된 값이 들어오는 것을 막는 성질)을 not null, check, foregin key를 통해 다중으로 잘 방어
-- 이 테이블에 존재하는 학번은 반드기 학생 테이블에 실제로 존재하는 학번이어야함(유령학생방지)참조 무결성

/*오류 상황*/
insert into 학생(학번, 이름, 생일, 학과번호)
values('50001','이윤주','2020-01-30','AA');

insert into 학생(이름, 생일, 학과번호)
values('이승은','2020-01-30','AA');

insert into 학생(학번, 이름, 생일, 학과번호)
values('50002','이승은','2020-01-30','AA');

insert into 학생(학번, 이름, 생일, 학과번호)
values('50003','백재용','2018-03-31','DD');

insert into 학과
values('AA','소프트웨어공학과','김남준');

insert into 학과
values('BB','소프트웨어공과','김남준');

insert into 학과
values('CC','디자인융합학과','박선영');

insert into 과목(과목번호, 과목명, 구분)
values('C0001','데이터베이스실습','전공');

show create table 과목;

insert into 과목(과목번호, 과목명, 구분, 학점)
values('C0001','데이터베이스실습','전공',3);

insert into 과목(과목번호, 과목명, 구분, 학점)
values('C0001','데이터베이스실습 설계와 구축','전공',5);

-- 학생 테이블에 설정되어 있는 제약조건 명세를 확인
select * 
from information_schema.table_constraints
where constraint_schema = '학사' and table_name = '학생';