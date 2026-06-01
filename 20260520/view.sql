-- 데이터베이스에서 사원 테이블을 사용하여 사원의 이름, 집전화, 입사일, 주소를 보이는 뷰를 작성하시오.
create or replace view view_사원
as
select 이름, 집전화 as 전화번호, 입사일, 주소
from 사원;

create or replace view view_사원(이름, 전화번호, 입사일, 주소)
as
select 이름, 집전화 as 전화번호, 입사일, 주소
from 사원;

select *
from view_사원

-- 제품 테이블, 주문세부 테이블을 조인하여 제품명과 주문수량합을 보이는 뷰를 작성
create or replace view view_제품주문별수량합
as
select 제품명, sum(주문수량) as 주문수량합
from 제품
inner join 주문세부
on 제품.제품번호 = 주문세부.제품번호
group by 제품명;
