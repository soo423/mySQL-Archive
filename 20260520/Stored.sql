/*SQL 스토어드 프로그램(Stored Program) - 개발자가 직접 작성해서 저장해 둔 프로그래밍 구문 전체
- 스토어드 프로시져(Stored Procedure - 자주 사용하는 복잡한 SQL 문장들과 프로그래밍 코드를 한데 묶어서 데이터베이스에 하나의 이름으로 저장해 둔 것, 함수(Function) 메서드(Method)개념)
- 스토어드 함수(Stored Function - 계산을 수행하고 반드시 하나의 결과값(Return)을 돌려주는 프로그래밍)
- 트리거(Trigger) : 테이블에 데이터가 입력/수정/삭제될 때 자동으로 알아서 실행되는 프로그램
*/

-- if문을 사용해 두개의 숫자 10과 5의 크기를 비교하는 프로시져
use company;

delimiter $$
create procedure proc_if()
	begin
		declare x int;
        declare y int default 5; -- var y=5
		set x = 10;
        if x > y then
			select 'x는 y보다 큽니다,' as 결과;
		else
			select 'x는 y보다 작거나 같습니다.' as 결과;
		end if;
    end $$
delimiter ;

call proc_if();
drop procedure if exists proc_if;

-- case문을 사용하여 숫자 10이 짝수인지 홀수인지 판별하는 프로시저 작성
delimiter $$
create procedure proc_case()
	begin
		declare x int default 10;
        declare y int;
        set y = 10 mod 2; -- 0
        case
			when y = 0 then
				select 'x는 짝수입니다.' as '결과';
			else
				select 'x는 홀수입니다.' as '결과';
			end case;
    end $$
delimiter ;

call proc_case();

-- 1부터 10까지의 합을 출력하는 프로시저 while문ㅇ로 작성
delimiter $$
create procedure proc_while()
	begin
		declare x int default 0;
        declare y int default 0;
        while x < 10 do
			set x = x + 1;
            set y = y + x;
		end while;
        select x, y;
    end $$
delimiter ;alter
call company.proc_while1();


-- 1부터 10까지 합을 출력하는 프로시저 루프문을 작성
delimiter $$
create procedure proc_loop1()
	begin
		declare x int default 0; -- 로컬변수 선언
        declare y int default 0;
        
        loop_sum:loop -- 탈출 조건이 없으면 무한 반복되므로 반복문 내에서 leave문을 사용해 루프 종료
			set x = x +1;
            set y = y + x;
            if x > 10 then
				leave loop_sum; -- leave는 break 역할, iterate는 continue 역할
			end if;
            select x, y;
		end loop;
    end $$
    
delimiter ;
call company.proc_loop();

-- 1부터 10까지 합을 출력하는 프로시저 repeat문을 작성
delimiter $$
create procedure proc_repeat2()
	begin
		declare x int default 0; -- 로컬변수 선언
        declare y int default 0;
        
        repeat -- 조건이 참이 될 때까지 코드 실행
			set x = x + 1;
            set y = y + x;
		until x >= 10 end repeat;
        select x, y;
	end $$
delimiter ;

call company.proc_repeat2();

/*스토어드 프로시저*/
-- 고객정보와 고객 수를 프로시저를 작성
delimiter $$
create procedure company.a_proc_고객정보4()
begin
	select * 
    from 고객;
    select count(*) as 고객수
    from 고객;
end $$
delimiter ;

call company.a_proc_고객정보4()