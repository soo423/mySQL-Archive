SELECT * FROM company.view_제품주문별수량합;

-- '여'사원에 대하여 사원의 이름, 집전화, 입사일, 주소, 성별을 보이는 뷰를 작성
create or replace view view_사원_여
as
select 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여'

/*뷰 조회하기 */
select *
from view_사원_여;

/*view_사원_여 뷰로 전화번호에 88이 들어간 사원 정보 검색*/
select * 
from view_사원_여
where 전화번호 like '%88%';

-- view_제품별주문수량합 뷰로 주문수량합이 1,200개 이상인 레코드를 검색
select * 
from view_제품별주문수량합
where 주문수량합 >=1200;

/*뷰 메타 정보 확인하기*/
select * 
from information_schema.views
where table_name = 'view_사원';

show create view view_사원;

/*뷰 삭제하기*/
drop view view_사원;

/*뷰를 통한 데이터 삽입*/
insert into view_사원_여(이름, 전화번호, 입사일, 주소, 성별)
values('황여름',(02)587-4989,'2023-02-10','서울시 강남구 청담동 23-5','여');
-- 	Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '587-4989,'2023-02-10',
-- '서울시 강남구 청담동 23-5','여')' at line 2	0.000 sec

create or replace view view_사원_여
as
select 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여';

insert into view_사원_여(사원번호, 이름, 전화번호, 입사일, 주소, 성별)
values('황여름',(02)587-4989,'2023-02-10','서울시 강남구 청담동 23-5','여');

/*데이터 삽입 조건*/
insert into view_제품별주문수량합
values('단짠 새우깡', 250);
-- 수정이 불가능한 형태의 뷰(non-updateable view)일때 발생함
/* view에 insert/update를 할 수 없는 조건들
집계함수를 사용한 경우(sum, avg, count, max, min) -> 뷰 대신 원본 테이블에 직접 데이터 넣기
group by 또는 having 절을 사용한 경우
distinct 키워드의 경우 (중복 제거)
union 또는 union all을 사용한 경우(여러 쿼리 병합)
join으로 만들어진 복잡한 뷰 중 일부 조건 미충족 시
*/

/*with check option*/
-- view_사원_여 뷰를 적용하여 "남"사원 정보 추가 후 결과 확인
insert into view_사원_여(사원번호, 이름, 입사일, 주소, 성별)
values('E13','강겨울','2023-02-10','서울시 성북구 장위동 123-7','남');

select * 
from view_사원_여
where 사원번호='E13';

create or replace view view_사원_여
as
select 사원번호, 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여'
with check option;

insert into view_사원_여(사원번호, 이름, 성별)
values('E14','유봄','남');

update view_사원_여
set 성별 = '남'
where 이름 = '황여름';

/* 인덱스 */
-- 날씨 테이블과 인덱스를 생성하시오.
create table 날씨
	(
		년도 int
        ,월 int
        ,일 int
        ,도시 varchar(20)
        ,기온 numeric(3,1)
        ,습도 int
        ,primary key(년도, 월, 일, 도시) --기본 인덱스
        ,index 기온인덱스(기온)
        ,index 도시인덱스(도시)
    );
    
/*
데이터베이스의 인덱스는 책의 맨 뒤에 있는 찾아보기(색인)과 똑같다.
인덱스는 조회(select) 성능을 극대화하기 위한 정렬된 색인표
기본키 인덱스(자동 생성) where 년도 2026 and 월 = 5 and 일 = 20 and 도시 = '서울'처럼
특정 날짜와 도시의 날씨를 찾을 때 빛의 속도로 찾아냄

기온인덱스(수동 생성)기온 커럶의 값들을 크기순(낮은 기온에서 높은 기온 순)으로 정렬한 별도의 색인 페이지를 만든다.
기온을 조건으로 검색하거나 정렬할 때 엄청나게 빨라진다
도시인덱스(수동생성) 도시 이름을 가나다순으로 정렬한 색인 페이지를 만든다
where 도시 = '부산' 처럼 특정 도시의 날씨만 모아서 보고 싶을 때 '부산'데이터만 쏙 골라옴


where 년도 = 2026 and 월 = 5;
where 년도 = 2026 or 월 = 5; -- or 조건은 인덱스를 무력화(성능 저하)
where 월 = 5 and 일 > 1; -- primary key(년도, 월, 일, 도시) 복합키일 경우 년도부터 시작
where 도시 like '%서울%'; -- % 와일드 카드 문자로 시작하는 경우 인덱스를 사용할 수 없음
where 도시 like '서울%'; -- 정상
*/

/*옵티마이저*/
-- 주문건수가 많은 고객 순으로 고객회사명별 주문건수를 보이는 쿼리의 실행 게획 확인
select 고객회사명, count(*) as 주문건수
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객회사명
order by count(*) desc;

-- 데이터베이스 내부에서 실제로 어떤 순서와 방식으로 실행되는지 그 청사진(실행 계획)을 트리 구조로 출력
-- format = tree 결과는 가장 안쪽(오른쪽으로 가장 많이 들어간 곳)에서부터 위쪽 방향으로 읽어나가는 것
-- 주문 테이블을 기준으로 고객 테이블을 인덱스 조인한 뒤, 임시 테이블을 만들어 그룹화, 마지막으로 정렬하여 결과를 냄

explain analyze -- 실행 계획 및 실행한 쿼리에 대한 통계를 함께 확인
select 고객회사명, count(*) as 주문건수
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객회사명
order by count(*) desc;

/*문제1*/
-- 피벗 형식으로 결과가 보이도록 뷰 작성
create or replace view view_도시_직위별_고객수
as
select 도시
	,sum(case when 담당자직위='대표이사' then 1 else 0 end) as '대표이사'
    ,sum(case when 담당자직위 like '영업%' then 1 else 0 end) as '영업'
    ,sum(case when 담당자직위 like '마케팅%' then 1 else 0 end) as '마케팅'
    ,sum(case when 담당자직위 like '회계%' then 1 else 0 end) as '회계'
from 고객
group by 도시;

create index 기온인덱스 on 날씨(기온); -- 인덱스 생성
alter table 날씨 add index 기온인덱스(기온); -- 테이블에서 인덱스 추가
alter table 날씨 drop index 기온인덱스; -- 테이블에서 인덱스 삭제
show index from 날씨; -- 테이블에 걸려있는 인덱스를 확인

/*데이터베이스의 인덱스는 책의 맨 뒤에 있는 '찾아보기(색인)'와 똑같다.
인덱스는 조회(SELECT) 성능을 극대화하기 위한 정렬된 색인표
기본키 인덱스 (자동 생성)　WHERE 년도 = 2026 AND 월 = 5 AND 일 = 20 AND 도시 = '서울' 처럼
특정 날짜와 도시의 날씨를 찾을 때 빛의 속도로 찾아 낸다.

기온인덱스 (수동 생성)　기온 컬럼의 값들을 크기순(낮은 기온에서 높은 기온 순)으로 정렬한 별도의 색인 페이지를 만든다.
기온을 조건으로 검색하거나 정렬할 때 엄청나게 빨라진다
도시인덱스 (수동 생성)　도시 이름을 가나다순으로 정렬한 색인 페이지를 만든다.
WHERE 도시 = '부산' 처럼 특정 도시의 날씨만 모아서 보고 싶을 때 '부산' 데이터만 쏙 골라 온다.

CUD(입력/수정/삭제) 속도 저하: 새로운 날씨 데이터가 INSERT 되거나 기존 기온이 UPDATE 되면,
데이터베이스는 실제 테이블뿐만 아니라 기온인덱스와 도시인덱스 페이지도 다시 정렬하고 갱신해야 한다.*/