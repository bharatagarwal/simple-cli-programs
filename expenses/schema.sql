-- create a database named expenses and run this inside there.

create table expenses (
  id serial primary key,
  amount numeric(6, 2) not null,
  memo text not null,
  created_on date not null
)

alter table expenses
add constraint positive_amount
check (amount > 0.00);

alter table expenses 
alter created_on set default now();
