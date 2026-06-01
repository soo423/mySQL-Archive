delimiter $$
create procedure d_proc_주문년도시_고객정보(
	in order_year int,
    in city varchar(50)
    )
begin
	select 고객.고객번호, 고객회사명, 도시, count(*) as 주문건수
    from 고객
    inner join 주문
    on 고객.고객번호 = 주문.고객번호
    where year(주문일) = order_year and 도시 = city collate utf8mb4_general_ci
    group by 고객.고객번호, 고객회사명;
end $$
delimiter ;

call d_proc_주문년도시_고객정보(2021, '공주시');

-- 고객회사명과 추가할 마일리지를 입력하면 해당 고객에 대하여 입력한 마일리지만큼 추가하는 프로시저 작성
delimiter $$
create procedure e_proc_고객회사명_마일리지추가(
	in company_name varchar(50),
    in add_mileage int
)
begin
	select 고객번호, 고객회사명, 마일리지 as 변경전마일리지
    from 고객
    where 고객회사명 = company_name collate utf8mb4_general_ci;
    set sql_safe_updates = 0;
    update 고객
    set 마일리지 = 마일리지 + add_mileage
    where 고객회사명 = company_name collate utf8mb4_general_ci;
	set sql_safe_updates = 1;
    select 고객번호, 고객회사명, 마일리지 as 변경후마일리지
    from 고객
    where 고객회사명 = company_name collate utf8mb4_general_ci;
end $$
delimiter ;

call e_proc_고객회사명_마일리지추가();

-- 고객회사명을 입력하면 해당 고객의 마일리지를 변경하는 프로시저를 작성

delimiter $$
create procedure f_proc_고객회사명_평균마일리지로변경(
	in company_name varchar(50)
)
begin
	declare 평균마일리지 int;
    declare 보유마일리지 int;
    
    select 고객회사명, 마일리지 as 변경전마일리지
    from 고객
    where 고객회사명 = company_name collate utf8mb4_general_ci;
    
    set 평균마일리지 = (select avg(마일리지) from 고객);
    set 보유마일리지 = (select 마일리지
					from 고객
					where 고객회사명 = company_name collate utf8mb4_general_ci);
	if(보유마일리지 > 평균마일리지) then
		update 고객
        set 마일리지 = 마일리지 + 100
        where 고객회사명 = company_name collate utf8mb4_general_ci;
	else
		update 고객
        set 마일리지 = 평균마일리지
        where 고객회사명 = company_name collate utf8mb4_general_ci;
	end if;
    select 고객회사명, 마일리지 as 변경후마일리지;
end $$
delimiter ;

call f_proc_고객회사명_평균마일리지로변경()

-- 고객회사명을 입력하면 고객의 보유 마일리지에 따라서 등급을 보이는 프로시저
-- 이때 고객의 마일리지가 100,000점 이상이면 '최우수고객회사', 50,000점 이상이면 '우수고객회사',
-- 그 나머지는 '관심고객회사'
delimiter $$
create procedure e_proc_고객등급(
	in company_name varchar(50),
    out grade varchar(50)
)
begin
	declare 보유마일리지 int; -- 프로시저 안에서만 임시로 쓸 수 있는 계산용 변수
    
    select 보유마일리지
    into 보유마일리지
    from 고객 
    where 고객회사명 = company_name collate utf8mb4_general_ci;
     if 보유마일리지 > 100000 then
		set grade = '최우수고객회사';
	elseif 보유마일리지 >= 50000 then
		set grade = '우수고객회사';
	else
		set grade = '관심고객회사';
	end if;
end $$
delimiter ;

call e_proc_고객등급('그린로더스', @그린로더스등급);
call e_proc_고객등급('오뚜락', @오뚜락등급);

select @그린로더스등급, 오뚜락등급

-- 인상율과 금액을 입력하면 인상금액을 입력하고,그 결과를 확인할 수 있는 프로시저 작성
delimiter $$ -- 프로시저 생성
create procedure g_proc_인상금액()
begin
	set price = price * (1 + increate_rate / 100);
end $$
delimiter $$

set @금액 = 10000; -- 외부에서 사용할 전역 변수 @금액을 만들고, 시작 값으로 10000(원)
call g_proc_인상금액(10, @금액);
select @금액; -- 값이 바꿔 @금액 변수를 최종 출력
drop procedure if exists g_proc_인상금액; -- 프로시저 삭제

-- 스토어드 함수
-- 수량과 단가를 입력하면 두 수를 곱하여 금액을 반환하는 함수
use company;
delimiter $$
create function f_func_금액(quantuty int, price int)
	returns int -- 반환 공식
-- mysql에 바이너리 로그(데이터 변경 이력)가 커져있을 때, 함수가 매번 똑같은 결과를 내는지(determinstic 입력값이 같으면 항상 똑같은 결과를 반환함)

begin
	declare amount int;
    set amount = quantity * price;
	return amount; -- 반환값
end $$
delimiter ;

select h_func_금액(100, 4500); -- 함수 실행
drop function h_func_금액; -- 함수 삭제

select *, func_금액(주문수량, 단가) as 주문금액
from 주문세부;

-- 트리거
-- insert, update, delete와 같은 이벤트가 발생할 때마다 트리거에 정의된 SQL문이 자동 실행
-- 변경 이력(로그)을 자동으로 남기기

-- 제품로그 테이블을 생성하시오, 제품을 추가할 때마다 로그 테이블에 정보를 남기는 트리거를 작성하시오
create table 제품로그
	(
		로그번호 int auto_increment primary key,
		-- 로그번호 int generated always as indentity primary key, -- 표준 SQL
        처리 varchar(10),
        내용 varchar(100),
        처리일 timestamp default current_timestamp()
    );

delimiter $$
create trigger trigger_제품제품로그
after insert on 제품 -- 제품 테이블에 새 데이터가 insert 된 직후에 이 트리거 발동
for each row -- 새로 들어온 행 하나마다(for each row), 누락 없이 변경 이력(로그)을 자동으로 남기기
begin
	insert into 제품로그(처리, 내용)
    values('insert', concat('제품번호:',new.제품번호, '제품명', new.제품명));
end $$
delimiter ;

insert into 제품(제품번호, 제품명, 단가, 재고)
values(99, '레몬캔디', 2000, 10);
-- 트리거 동작 여부는 제품 테이블에 레코드를 추가하고 제품로그 테이블을 검색하여 확인

select * from 제품 where 제품번호 = 99;
select * from 제품로그;

-- 제품 테이블에서 단가나 재고가 변경되면 변경된 사항을 제품로그 테이블에 저장하는 트리거를 생성
delimiter $$
create trigger trigger_제품변경로그
after update on 제품
for each row
begin
	if(new.단가 <> old.단가) then
		insert into 제품로그(처리, 내용)
		values('update', concat('제품번호:', old.제품번호, '단가:', old.단가, '->', new.단가));
	end if;
    
	if(new.단가 <> old.단가) then
		insert into 제품로그(처리, 내용)
		values('update', concat('제품번호:', old.제품번호, '단가:', old.재고, '->', new.재고));
	end if;
end $$
delimiter ;

update 제품
set 단가 = 2500
where 제품번호 = 99;

select * from 제품로그;

-- 제품 테이블에서 제품 정보를 삭제하면 삭제된 레코드의 정보를 제품로그 테이블에 저장하는 트리거 생성
delimiter $$
create trigger trigger_제품삭제로그
after delete on 제품
for each row
begin
	insert into 제품로그(처리, 내용)
    values('delete', concat('제품번호:', old.제품번호, '제품명:', old.제품명));
end $$
delimiter ;

delete from 제품
where 제품번호 = 99;

select * from 제품로그;

/*문제1*/
-- 제품명의 일부를 입력하면 해당 제품들에 대해 제품명별로 주문수량합, 주문금액합을 보이는 프로시저를 작성하시오.
delimiter $$
create procedure proc_제품명_주문내역()
begin
	select 제품명
			, sum(주문수량) as 주문수량합
            , sum(주문세부.단가 * 주문수량) as 주문금액합
	from 제품
    inner join 주문세부
    on 제품.제품번호 = 주문번호.제품번호
    where 제품명 like concat('%', product_name collate utf8mb4_general_ci, '%')
	group by 제품명;
end $$
delimiter ;

call proc_제품명_주문내역('캔디');

/*문제2*/
-- 생일을 입력하면 연령구분을 반환하는 함수를 생성하시오.
delimiter $$
create function func_연령구분(birthday)
	returns varchar(20)
    deterministic
begin
	declare 나이 int;
    declare 연령구분 varchar(20);
    
    set 나이 = year(now() - year(birthday);
    set 연령구분 = (select case
							when 나이 < 20 then '미성년'
                            when 나이 < 30 then '청년층'
                            when 나이 < 55 then '중년층'
                            when 나이 < 70 then '장년층'
                            else '노년층'
					end);
	return 연령구분;
end $$
delimiter ;

select func_연령구분('2002-01-01');

select 이름, 생일, year(생일), date_format(생일,ㅡ '%Y'), substring(생일, 1, 4)
from 사원;

select 이름, 생일, year(생일), yar(now()) - year(생일) as 나이,
		func_연령구분(생일) as 연령구분
from 사원;