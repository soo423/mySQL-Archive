/*Windows 함수 : 기존 행들의 관계를 유지하면서, 특정 '창문' 영역을 지정해 그 안에서만 계산을 수행
Over 절 : 함수가 계산될 데이터의 범위(윈도우)를 정의, 생략 시 전체 테이블을 하나의 윈도우로 봄
over(partition by 파티션 지정 : group by와 비슷하지만 행을 합치지 않고 묶기만 함
over(order by) 파티션 내에서 데이터가 계산될 순서*/


/*집계 윈도우 함수 : sum, avg, count, max, min*/
-- 부산광역시 고객에 대하여 고객번호, 고객회사명, 마일리지와 평균 마일리지를 함께 보이시오.
select 고객번호, 고객회사명, 마일리지, avg(마일리지) over() as 평균마일리지
from 고객
where 도시 = '부산광역시';

/*순위 윈도우 함수 : row_number, rank, dense_rank*/
-- 부산광역시 고객에 대해 고객번호, 고객회사명, 마일리지, 평균마일리지, 그리고 각 고객의 마일리지와 평균마일리지 간의 차이를 찾
select 고객번호, 고객회사명, 마일리지
			, avg(마일리지) over() as 평균마일리지
            , 마일리지 - avg(마일리지) over() as 차이
from 고객
where 도시 = '부산광역시';

-- 경기도 고객에 대하여 고객번호, 도시, 마일리지, 도시의 평균마일리지, 그리고 각 고객의 마일리지와 도시의 평균마일리지를 찾으시오'
-- partition by : 전체 집합을 특정 기준에 의해 소그룹으로나누고자 할 때
select 고객번호, 도시, 마일리지 as 고객마일리지
		, avg(마일리지) over(partition by 도시) as 도시평균마일리지
        , 마일리지 - avg(마일리지) over(partition by 도시) as 차이
from 고객
where 지역 = '경기도';

select 도시, avg(마일리지) as 평균마일리지
from 고객
where 지역 = '경기도'
group by 도시;

/*행 순서 윈도우 함수 :  lead, lag, first_value, last_value*/
select 고객번호, 고객회사명, 담당자명, 마일리지
		, rank() over(order by 마일리지 desc) as 순위
from 고객
where 도시 = '부산광역시';

-- '경기도'고객에 대하여 마일리지가 많은 고객부터 순위를 매기시오.
select 고객번호, 고객회사명, 담당자명, 마일리지
		, rank() over(partition by 도시 order by 마일리지 desc) as 순위
from 고객
where 도시 = '경기도';

-- '시럽'제품에 대해 단가 기준으로 백분율 순위를 보이시오, 결과값 범위 : 0<= 결과
-- 수식 : (1-1)/(5-1)
--		()
select 제품명, 단가
		,percent_rank() over(order by 단가) as 백분율순위
from 제품
where 제품명 like '%시럽';

-- 부산광역시 고객에 대하여 고객번호, 고객회사명, 마일리지 및 마일리지를 기준으로 한 누적 분포 값을 보이시오
-- 누적분포(cumulative distribution)의 약자, 누적 백분율, 결과값 범위 : 0< 결과값 <=1
select 고객번호, 고객회사명, 마일리지
		,cume_dist() over() as 누적분포
from 고객
where 도시 = '부산광역시';

-- '인천광역시' 고객에 대해 마일리리즐 기준으로 하여 3개 그룹으로 나누시오
-- ntile() : 그룹으로 나누고 차례대로 그룹 번호를 부여

select 고객번호, 도시, 마일리지
		,ntile(2) over(partition by 도시 order by 마일리지) as 그룹
from 고객
where 도시 = '인천광역시';

-- 동일 지역 고객별로 마일리지가 많은 순서로 순위를 매기시오.
select 고객번호, 고객회사명, 도시, 마일리지
		,rank() over(partition by 지역 order by 마일리지 desc) as 순위
from 고객;

-- 부산광역시 고객에 대하여 고객회사명, 마일리지, 최소 마일리지를 가진 고객회사명, 최소 마일리지,
-- rows between unbounded preceding and unbounded following 행 처음부터 행 끝까지 다 봐라
-- rows between curremt row and unbounded following 현재 행부터 행 끝까지 봐라
-- 마일리지와 최소마일리지와의 차이를 보이시오.
-- first_value() : 정렬된 값의 첫번째 값을 반환
select 고객회사명, 마일리지
		,first_value(고객회사명) over(order by 마일리지 rows between unbounded preceding and unbounded following) as 최소마일리지보유고객
        ,first_value(고객회사명) over(order by 마일리지 rows between unbounded preceding and unbounded following) as 최소마일리지
        ,마일리지 - first_value(마일리지) over(order by 마일리지) as 차이
from 고객
where 도시 = '부산광역시';

-- max() 전체 범위 중 가장 큰 값
select 고객회사명, 마일리지
		,max(마일리지) over() as 최대마일리지
from 고객
where 도시 = '부산광역시';

-- 이전 행의 고객번호, 현재 행의 고객번호, 다음 행의 고객번호를 보이시오.
-- lag() 이전행
-- lead() 다음행
select lag(고객번호) over(order by 고객번호) as 이전행고객번호
		, 고객번호
        , lead(고객번호) over(order by 고객번호) as 다음행고객번호
from 고객;

-- '부산광역시' 고객에 대하여 고객의 정보와 마일리지가 세 번째로 적은 고객의 정보를 함께 보이시오.

select 고객번호, 고객회사명, 마일리지
		,nth_value(고객회사명, 3) over(order by 마일리지) as '3번째로 마일리지가 적은 고객'
        ,nth_value(마일리지, 3) over(order by 마일리지) as '3번째 마일리지'
from 고객
where 도시 = '부산광역시';

/* 문제 1 */
-- 2021년도의 주문에 대해 월별 주문금액합과 월별 주문금액합에 대한 누적합을 보이시오.
-- where 없이 여러 연도를 한번에 조회하면서 연도 별 누적을 원할때는 pratition by year()를 쓴다.
-- 2021년 전체를 하나의 흐름으로 월별 누적
select month(주문.주문일) as 월
		,sum(주문세부.단가 * 주문세부.주문수량 * (1- 주문세부.할인율)) as 월별주문금액합
        ,sum(
			sum(주문세부.단가 * 주문세부.주문수량 * (1 - 주문세부.할인율))
            ) over(order by month(주문.주문일)
            rows between unbounded preceding and current row) as 누적주문금액합
from 주문
inner join 주문세부
on 주문.주문번호 = 주문세부.주문번호
where year(주문.주문일) = 2021
group by month(주문.주문일)
order by 월;
/* 문제 2*/
-- 2021년도의 주문에 대해 분기별 주문건수, 첫 분기 주문건수, 마지막 분기 주문건수,
-- 현 분기와 첫 분기 간의 주문건수 차이, 현 분기와 마지막 분기 간 주문건수의 차이를 보이시오.
select 분기, 분기별주문건수
		,first_value(분기별주문건수) over (order by 분기 rows between unbounded preceding and unbounded following) as 첫분기주문건수
        ,last_value(분기별주문건수) over (order by 분기 rows between unbounded preceding and unbounded following) as 마지막분기주문건수
        ,분기별주문건수 - first_value(분기별주문건수) over (order by 분기 rows between unbounded preceding and unbounded following) as 첫분기와의차이
        ,분기별주문건수 - first_value(분기별주문건수) over (order by 분기 rows between unbounded preceding and unbounded following) as 마지막분기와의차이
from ( -- 분기별 줌누건수 먼저 집계(인라인 뷰), group by 결과에 바로 윈도우 함수ㄹㄹ 쓸 수 없어서 인라인 뷰로
	select quarter(주문일) as 분기
				,count(*) as 분기별주문건수
	from 주문
    where year(주문일) = 2021
    group by quarter(주문일)
) as 분기집계
order by 분기;

/* 문제 3 */
-- 2021년도 주문에 대해 월별로 당월 주문건수, 차월 주문건수, 차차월 주문건수를 보이시오.
select 월, 월별주문건수 as 당월주문건수
		,lead(월별주문건수, 1) over(order by 월) as 차월주문건수
        ,lead(월별주문건수, 2) over(order by 월) as 차차월주문건수
from( -- 월별 주무건수 먼저 집계(인라인 뷰)
	select month(주문일) as 월
			,count(*) as 월별주문건수
	from 주문
	where year(주문일) = 2021
    group by month(주문일)
)as 월집계
order by 월;