#!/bin/bash

if [ "$#" -ne 3 ]
then
        echo "Syntax: $0 'starting-date-YYYY-MM-DD' 'pay-rise-file.csv' 'mysql-connection'"
        exit 1
fi

if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! date -d "$1" >/dev/null 2>&1
        then echo "Date $1 is an invalid format (YYYY-MM-DD)"
        exit 1
fi


while IFS=, read -r emp_no pay_rise
do
        SQL="   start transaction; \
                select salary, from_date into @salary, @last_date from salaries \
                where emp_no = $emp_no and to_date = \"9999-01-01\"; \
                update salaries set to_date = date_add(\"$1\", interval -1 day) \
                where emp_no = $emp_no and to_date = \"9999-01-01\"; \
                insert into salaries (emp_no, salary, from_date, to_date) \
                values ($emp_no, round(@salary * (1 + $pay_rise / 100), 0), \"$1\", \"9999-01-01\"); \
                commit;"

        eval $3 " <<< '$SQL'"


done < $2
