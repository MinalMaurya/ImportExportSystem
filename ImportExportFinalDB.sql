drop database import_export;
create database if not exists import_export;
use import_export;

drop table if exists consumer_port;
drop table if exists seller_port;

-- Create consumer table------------Minal Maurya 
create table consumer_port (
    port_id varchar(50) primary key,
    password varchar(40) not null,
    location varchar(255),
    role varchar(20) not null default 'consumer'
);

-- Create seller table
create table seller_port (
    port_id varchar(50) primary key,
    password varchar(40) not null,
    location varchar(255),
    role varchar(20) not null default 'seller'
);

-- Log table for trigger demonstration
drop table if exists port_logs;
create table port_logs (
    id int auto_increment primary key,
    port_id varchar(50),
    action varchar(20),
    role varchar(20),
    action_time timestamp default current_timestamp
);

delimiter &&
delimiter $$

drop procedure if exists update_user_details $$
create procedure update_user_details(
    in p_port_id varchar(50),
    in p_new_password varchar(40),
    in p_new_location varchar(255),
    in p_role varchar(20)
)
begin
    declare user_count int;

    if p_role not in ('consumer', 'seller') then
        select 'error: role must be consumer or seller' as message;

    elseif p_role = 'consumer' then
        select count(*) into user_count from consumer_port where port_id = p_port_id;

        if user_count = 0 then
            select 'error: consumer not found' as message;
        else
            update consumer_port
            set 
                password = ifnull(p_new_password, password),
                location = ifnull(p_new_location, location)
            where port_id = p_port_id;

            select 'consumer details updated successfully' as message;
        end if;

    elseif p_role = 'seller' then
        select count(*) into user_count from seller_port where port_id = p_port_id;

        if user_count = 0 then
            select 'error: seller not found' as message;
        else
            update seller_port
            set 
                password = ifnull(p_new_password, password),
                location = ifnull(p_new_location, location)
            where port_id = p_port_id;

            select 'seller details updated successfully' as message;
        end if;
    end if;
end $$
 delimiter &&
-- Trigger: After insert on consumer_port
create trigger trg_consumer_insert
after insert on consumer_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (new.port_id, 'insert', new.role);
end &&


delimiter &&
-- Trigger: After update on consumer_port
create trigger trg_consumer_update
after update on consumer_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (new.port_id, 'update', new.role);
end &&

-- Trigger: After delete on consumer_port
create trigger trg_consumer_delete
after delete on consumer_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (old.port_id, 'delete', old.role);
end &&

-- Trigger: After insert on seller_port
create trigger trg_seller_insert
after insert on seller_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (new.port_id, 'insert', new.role);
end &&

-- Trigger: After update on seller_port
create trigger trg_seller_update
after update on seller_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (new.port_id, 'update', new.role);
end &&

-- Trigger: After delete on seller_port
create trigger trg_seller_delete
after delete on seller_port
for each row
begin
    insert into port_logs(port_id, action, role)
    values (old.port_id, 'delete', old.role);
end &&

-- Registration procedure
drop procedure if exists register_user &&

create procedure register_user(
    in r_port_id varchar(50),
    in r_password varchar(40),
    in r_confirm_password varchar(255),
    in r_role varchar(20)
)
begin
    declare user_count int;

   
    if char_length(r_password) < 8 then
        select 'error: password must be at least 8 characters' as message;

    elseif r_password <> r_confirm_password then
        select 'error: passwords do not match' as message;

    else
        if r_role = 'consumer' then
            select count(*) into user_count from consumer_port where port_id = r_port_id;

            if user_count > 0 then
                select 'error: consumer port_id already registered' as message;
            else
                insert into consumer_port(port_id, password, role)
                values(r_port_id, r_password, 'consumer');
                select 'register successfully as consumer' as message;
            end if;

        elseif r_role = 'seller' then
            select count(*) into user_count from seller_port where port_id = r_port_id;

            if user_count > 0 then
                select 'error: seller port_id already registered' as message;
            else
                insert into seller_port(port_id, password, role)
                values(r_port_id, r_password, 'seller');
                select 'register successfully as seller' as message;
            end if;

        else
            select 'error: role must be consumer or seller' as message;
        end if;
    end if;
end &&
-- Login procedure
drop procedure if exists login_user &&
create procedure login_user(
    in l_port_id varchar(50),
    in l_password varchar(40),
    in l_role varchar(20)
)
begin
    declare login_count int;

    -- Password must be at least 8 characters
    if char_length(l_password) < 8 then
        select 'error: password must be at least 8 characters' as message;

    elseif l_role not in ('consumer','seller') then
        select 'error: role must be consumer or seller' as message;

    elseif l_role = 'consumer' then
        select count(*) into login_count
        from consumer_port
        where port_id = l_port_id and password = l_password;

        if login_count > 0 then
            select 'login successful' as message;
        else
            select 'invalid port id or password' as message;
        end if;

    elseif l_role = 'seller' then
        select count(*) into login_count
        from seller_port
        where port_id = l_port_id and password = l_password;

        if login_count > 0 then
            select 'login successful' as message;
        else
            select 'invalid port id or password' as message;
        end if;

    end if;
end &&
delimiter ;

-- -\edit profile ------ ANISHA
drop procedure if exists edit_profile;

delimiter $$

drop procedure if exists edit_profile $$
create procedure edit_profile(
    in p_port_id varchar(50),
    in p_role varchar(20),
    in new_password varchar(255),
    in new_location varchar(100),
    in update_password_flag boolean,
    in update_location_flag boolean,
    in delete_flag boolean
)
begin
    -- check role validity
    if p_role not in ('consumer', 'seller') then
        signal sqlstate '45000' set message_text = 'invalid role: must be consumer or seller';
    end if;

    -- check if port_id exists
    if p_role = 'consumer' then
        if not exists (select 1 from consumer_port where port_id = p_port_id) then
            signal sqlstate '45000' set message_text = 'consumer not found';
        end if;
    elseif p_role = 'seller' then
        if not exists (select 1 from seller_port where port_id = p_port_id) then
            signal sqlstate '45000' set message_text = 'seller not found';
        end if;
    end if;

    -- if role is consumer
    if p_role = 'consumer' then

        if delete_flag then
            delete from orders where consumer_port_id = p_port_id;
            delete from reported_products where consumer_port_id = p_port_id;
            delete from consumer_port where port_id = p_port_id;
            select 'consumer profile deleted successfully' as status;
        else
            if update_password_flag then
                if new_password is null then
                    signal sqlstate '45000' set message_text = 'password cannot be null';
                end if;
                update consumer_port set password = new_password where port_id = p_port_id;
            end if;

            if update_location_flag then
                if new_location is null then
                    signal sqlstate '45000' set message_text = 'location cannot be null';
                end if;
                update consumer_port set location = new_location where port_id = p_port_id;
            end if;

            select 'consumer profile updated successfully' as status;
        end if;

    -- if role is seller
    elseif p_role = 'seller' then

        if delete_flag then
            delete from orders where seller_port_id = p_port_id;
            delete from reported_products where seller_port_id = p_port_id;
            delete from products where seller_port_id = p_port_id;
            delete from seller_port where port_id = p_port_id;
            select 'seller profile deleted successfully' as status;
        else
            if update_password_flag then
                if new_password is null then
                    signal sqlstate '45000' set message_text = 'password cannot be null';
                end if;
                update seller_port set password = new_password where port_id = p_port_id;
            end if;

            if update_location_flag then
                if new_location is null then
                    signal sqlstate '45000' set message_text = 'location cannot be null';
                end if;
                update seller_port set location = new_location where port_id = p_port_id;
            end if;

            select 'seller profile updated successfully' as status;
        end if;
    end if;

end $$
delimiter ;

drop procedure if exists get_user_details $$
delimiter $$

drop procedure if exists get_user_details $$
create procedure get_user_details(
    in p_port_id varchar(50),
    in p_role varchar(20)
)
begin
    if p_role = 'consumer' then
        select port_id, password, location
        from consumer_port
        where port_id = p_port_id;

    elseif p_role = 'seller' then
        select port_id, password, location
        from seller_port
        where port_id = p_port_id;

    else
        signal sqlstate '45000'
        set message_text = 'Invalid role';
    end if;
end $$
delimiter ;
SELECT * FROM port_logs;
select * from seller_port;
select * from consumer_port;

--  Products ----------- ARPIT

-- 3. products table
drop table if exists products;
create table products (
    product_id int auto_increment primary key,
    seller_port_id varchar(50) not null,
    product_name varchar(255) not null,
    quantity int not null,
    price decimal(10,2) not null,
    foreign key (seller_port_id) references seller_port(port_id)
        on delete cascade
        on update cascade
);

-- 4. product_logs table
drop table if exists product_logs;
create table product_logs (
    log_id int auto_increment primary key,
    product_id int,
    seller_port_id varchar(50),
    action varchar(25),
    product_name varchar(255),
    quantity int,
    price decimal(10,2),
    log_time timestamp default current_timestamp
);

-- 5. procedure: reset auto_increment
delimiter $$

drop procedure if exists reset_auto_increment $$
create procedure reset_auto_increment()
begin
    declare max_id int;
    select ifnull(max(product_id), 0) into max_id from products;
    set @sql = concat('alter table products auto_increment = ', max_id + 1);
    prepare stmt from @sql;
    execute stmt;
    deallocate prepare stmt;
end $$

delimiter ;

-- 6. procedure: add product (with duplicate check)
delimiter $$

drop procedure if exists add_product $$
create procedure add_product(
    in p_seller_port_id varchar(50),
    in p_product_name varchar(255),
    in p_quantity int,
    in p_price decimal(10,2)
)
begin
    declare exists_id int;

    select product_id into exists_id
    from products
    where seller_port_id = p_seller_port_id and product_name = p_product_name
    limit 1;

    if exists_id is null then
        insert into products (seller_port_id, product_name, quantity, price)
        values (p_seller_port_id, p_product_name, p_quantity, p_price);
    end if;

    call reset_auto_increment();
end $$

delimiter ;

-- 7. procedure: update product
delimiter $$

drop procedure if exists update_product $$
create procedure update_product(
    in p_product_id int,
    in p_product_name varchar(255),
    in p_quantity int,
    in p_price decimal(10,2)
)
begin
    update products
    set 
        product_name = ifnull(p_product_name, product_name),
        quantity = ifnull(p_quantity, quantity),
        price = ifnull(p_price, price)
    where product_id = p_product_id;

    call reset_auto_increment();
end $$

delimiter ;

-- 8. procedure: delete product
delimiter $$

drop procedure if exists delete_product $$
create procedure delete_product(in p_product_id int)
begin
    delete from products where product_id = p_product_id;
    call reset_auto_increment();
end $$

delimiter ;

-- 9. procedure: list products by seller
delimiter $$

drop procedure if exists list_products_by_seller $$
create procedure list_products_by_seller(in p_seller_port_id varchar(50))
begin
    select 
        product_id, 
        seller_port_id,
        product_name, 
        quantity, 
        price
    from products
    where seller_port_id = p_seller_port_id;
end $$

delimiter ;

-- 10. procedure: list all products
delimiter $$

drop procedure if exists list_products $$
create procedure list_products()
begin
    select * from products;
end $$

delimiter ;

-- 11. trigger: after insert
delimiter $$

drop trigger if exists trg_product_insert $$
create trigger trg_product_insert
after insert on products
for each row
begin
    insert into product_logs(product_id, seller_port_id, action, product_name, quantity, price)
    values (
        new.product_id,
        new.seller_port_id,
        'insert',
        new.product_name,
        new.quantity,
        new.price
    );
end $$

delimiter ;

-- 12. trigger: after update
delimiter $$

drop trigger if exists trg_product_update $$
create trigger trg_product_update
after update on products
for each row
begin
    declare change_type varchar(25);

    if new.price <> old.price and new.quantity = old.quantity then
        set change_type = 'price_update';
    elseif new.price = old.price and new.quantity <> old.quantity then
        set change_type = 'quantity_update';
    elseif new.price <> old.price and new.quantity <> old.quantity then
        set change_type = 'price_quantity_update';
    else
        set change_type = 'general_update';
    end if;

    insert into product_logs(product_id, seller_port_id, action, product_name, quantity, price)
    values (
        new.product_id,
        new.seller_port_id,
        change_type,
        new.product_name,
        new.quantity,
        new.price
    );
end $$

delimiter ;


-- sales analysis procedure for seller dashboard.  -- ----------------MINAL
delimiter $$

-- basic seller sales
drop procedure if exists get_seller_sales $$
create procedure get_seller_sales(in sellerid varchar(50))
begin
  select 
    p.product_name,
    sum(o.quantity) as total_units_sold,
    sum(o.quantity * p.price) as total_sales,
    max(o.order_date) as last_order_date
  from orders o
  join products p on o.product_id = p.product_id
  where o.delivered = true and o.seller_port_id = sellerid
  group by p.product_id;
end $$


DROP PROCEDURE IF EXISTS get_seller_sales_monthly_with_dates;

delimiter $$

drop procedure if exists get_seller_sales_monthly_with_dates $$

create procedure get_seller_sales_monthly_with_dates(
    in sellerid varchar(50),
    in fromdate date,
    in todate date
)
begin
  select 
    p.product_name,
    sum(o.quantity) as total_units_sold,
    avg(p.price) as unit_cost,
    sum(o.quantity * p.price) as total_sales,
    max(o.order_date) as last_order_date
  from orders o
  join products p on o.product_id = p.product_id
  where o.delivered = true
    and o.seller_port_id = sellerid
    and o.order_date between fromdate and todate
  group by p.product_id
  order by total_units_sold desc;
end $$

delimiter ;

DROP PROCEDURE IF EXISTS get_seller_sales_yearly_with_dates;
DELIMITER $$

CREATE PROCEDURE get_seller_sales_yearly_with_dates(
    IN sellerid VARCHAR(50),
    IN fromDate DATE,
    IN toDate DATE
)
BEGIN
  SELECT 
    p.product_name,
    SUM(o.quantity) AS total_units_sold,
    AVG(p.price)    AS unit_cost,
    SUM(o.quantity * p.price) AS total_sales,
    MAX(o.order_date) AS last_order_date
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  WHERE o.delivered = TRUE
    AND o.seller_port_id = sellerid
    AND o.order_date BETWEEN fromDate AND toDate
  GROUP BY p.product_id
  ORDER BY total_units_sold DESC;
END $$

DELIMITER ;
-- ------------ orders -------- AADESH

create table if not exists orders (
    order_id int primary key auto_increment,
    product_id int,
    consumer_port_id varchar(20) not null,
    seller_port_id varchar(20) not null,
    quantity int,
    order_date date not null default (curdate()),

    order_placed boolean default true,
    shipped boolean default false,
    out_for_delivery boolean default false,
    delivered boolean default false,
    status_change_time datetime default current_timestamp,

    total_amount decimal(10,2),

    cancelled boolean default false,
    cancellation_reason varchar(255),
    cancelled_date date,
    foreign key (product_id) references products(product_id),
foreign key (consumer_port_id) references consumer_port(port_id),
foreign key (seller_port_id) references seller_port(port_id)
);

-- 4. Add Order (by product_name)
delimiter $$

drop procedure if exists add_order $$
create procedure add_order(
    in add_product_name     varchar(100),
    in add_consumer_port_id varchar(20),
    in add_seller_port_id   varchar(20),
    in add_quantity         int
)
begin
    declare prod_id         int;
    declare prod_price      decimal(10,2);
    declare available_qty   int;

    -- fetch product id, price and current stock
    select product_id, price, quantity
      into prod_id, prod_price, available_qty
      from products
     where product_name     = add_product_name
       and seller_port_id   = add_seller_port_id
     limit 1;

    -- if not enough stock, abort
    if add_quantity > available_qty then
        signal sqlstate '45000'
          set message_text = 'insufficient stock for this product';
    end if;

    -- insert the order
    insert into orders (
        product_id,
        consumer_port_id,
        seller_port_id,
        quantity,
        total_amount,
        order_date
    )
    values (
        prod_id,
        add_consumer_port_id,
        add_seller_port_id,
        add_quantity,
        add_quantity * prod_price,
        now()
    );

    -- decrement stock
    update products
       set quantity = quantity - add_quantity
     where product_id = prod_id;

    commit;
end $$
delimiter ;

-- 5. Get All Orders

delimiter $$
drop procedure if exists get_orders $$
create procedure get_orders()
begin
    select 
        o.order_id,
        p.product_name,
        o.product_id,
        o.consumer_port_id,
		cp.location as consumer_location,
        o.seller_port_id,
        o.quantity,
        o.total_amount,
        o.order_date,
        o.order_placed,
        o.shipped,
        o.out_for_delivery,
        o.delivered,
        o.status_change_time,
        o.cancelled
        
    from orders o
    join products p on o.product_id = p.product_id
    join consumer_port cp on o.consumer_port_id = cp.port_id;
end $$
delimiter ;

-- 6. Update Order Status
delimiter $$
drop procedure if exists update_order_status $$
create procedure update_order_status(
    in update_order_id int,
    in new_status varchar(50)
)
begin
    if exists (
        select 1 from orders where order_id = update_order_id and cancelled = true
    ) then
        signal sqlstate '45000'
        set message_text = 'cannot update: order is cancelled';
    end if;

    if new_status = 'shipped' then
        update orders
        set
            order_placed = false,
            shipped = true,
            out_for_delivery = false,
            delivered = false,
            status_change_time = current_timestamp
        where order_id = update_order_id;

    elseif new_status = 'out for delivery' then
        update orders
        set
            order_placed = false,
            shipped = true,
            out_for_delivery = true,
            delivered = false,
            status_change_time = current_timestamp
        where order_id = update_order_id;

    elseif new_status = 'delivered' then
        update orders
        set
            order_placed = false,
            shipped = true,
            out_for_delivery = true,
            delivered = true,
            status_change_time = current_timestamp
        where order_id = update_order_id;

    else
        signal sqlstate '45000'
        set message_text = 'invalid status. use: shipped, out for delivery, delivered';
    end if;
end $$
delimiter ;


-- 7. Cancel Order
delimiter $$
drop procedure if exists cancel_order $$
create procedure cancel_order(
    in cancel_order_id int,
    in reason varchar(255)
)
begin
  declare current_shipped boolean;
  declare current_delivered boolean;
  declare prod_id int;
  declare qty int;

  select shipped, delivered, product_id, quantity
    into current_shipped, current_delivered, prod_id, qty
  from orders
  where order_id = cancel_order_id;

  if current_shipped = false and current_delivered = false then
    update orders
      set cancelled = true,
          cancellation_reason = reason,
          cancelled_date = curdate()
    where order_id = cancel_order_id;
    update products
      set quantity = quantity + qty
    where product_id = prod_id;
  else
    signal sqlstate '45000'
      set message_text = 'cannot cancel: order already shipped or delivered';
  end if;
end $$
delimiter ;

-- 8. Delete Cancelled Order

delimiter $$
drop procedure if exists delete_order $$
create procedure delete_order(
    in delete_order_id int
)
begin
    delete from orders
    where order_id = delete_order_id and cancelled = true;
end $$
delimiter ;

-- 9. Track Order
DELIMITER $$
DROP PROCEDURE IF EXISTS track_status $$
CREATE PROCEDURE track_status(IN oid INT)
BEGIN
    if not exists (select 1 from orders where order_id = oid) then
        signal sqlstate '45000'
        set message_text = 'Error: No such order ID exists';
    end if;
    SELECT 
        o.order_id,
        o.consumer_port_id,
        o.seller_port_id, 
        p.product_name,
        o.product_id,
        o.quantity,
        o.total_amount,
        o.order_date,
        o.order_placed,
        o.shipped,
        o.out_for_delivery,
        o.delivered,
        o.status_change_time,
        o.cancelled,
        o.cancellation_reason,
        o.cancelled_date
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.order_id = oid;
END $$
DELIMITER ;

-- 10. Update Order Quantity

delimiter $$
drop procedure if exists update_order_quantity $$
create procedure update_order_quantity(
    in oid int,
    in new_quantity int
)
begin
    declare prod_id int;
    declare old_quantity int;
    declare prod_price decimal(10,2);

    select product_id, quantity into prod_id, old_quantity
    from orders where order_id = oid;

    select price into prod_price from products where product_id = prod_id;

    update products
    set quantity = quantity + old_quantity
    where product_id = prod_id;

    update orders
    set quantity = new_quantity,
        total_amount = new_quantity * prod_price
    where order_id = oid;

    update products
    set quantity = quantity - new_quantity
    where product_id = prod_id;
end $$
delimiter ;

-- 11. Trigger: Quantity > 0 Before Insert
delimiter $$
drop trigger if exists before_order_insert $$
create trigger before_order_insert
before insert on orders
for each row
begin
    if new.quantity <= 0 then
        signal sqlstate '45000'
        set message_text = 'quantity must be greater than 0';
    end if;
end $$
delimiter ;

-- 12. Trigger: Prevent Update on Cancelled or Delivered
delimiter $$
drop trigger if exists before_order_update $$
create trigger before_order_update
before update on orders
for each row
begin
    if old.cancelled = true then
        signal sqlstate '45000'
        set message_text = 'cannot update cancelled order';
    end if;

    if old.delivered = true then
        signal sqlstate '45000'
        set message_text = 'order already delivered';
    end if;
end $$
delimiter ;

create table cart (
    cart_id int auto_increment primary key,
    consumer_port_id varchar(50),
    product_id int,
    quantity int,
    added_on datetime default current_timestamp,
    foreign key (consumer_port_id) references consumer_port(port_id),
    foreign key (product_id) references products(product_id)
);
drop procedure if exists add_to_cart;

delimiter $$

create procedure add_to_cart (
    in p_consumer_id varchar(50),
    in p_product_id int,
    in p_quantity int
)
begin
    declare existing_qty int;

    -- check if product already exists in cart
    select quantity into existing_qty
    from cart
    where consumer_port_id = p_consumer_id
      and product_id = p_product_id;

    if existing_qty is not null then
        -- update existing quantity
        update cart
        set quantity = quantity + p_quantity,
            added_on = current_timestamp
        where consumer_port_id = p_consumer_id
          and product_id = p_product_id;
    else
        -- insert new item into cart
        insert into cart (consumer_port_id, product_id, quantity)
        values (p_consumer_id, p_product_id, p_quantity);
    end if;
end $$

delimiter ;
-- ------------- reported_order -- ———————————SAIGANESH 
drop table reported_products;
create table if not exists reported_products (
    report_id      int auto_increment primary key,
    product_id     int            not null,
    consumer_port_id varchar(50)  not null,
    seller_port_id   varchar(50)  not null,
    issue_type       enum('damaged','wrong_product','delay','still_not_received','missing') not null,
    status           enum('pending','solved') not null default 'pending',
    action_taken     enum('replacement','compensation','resend','refund','pending') not null default 'pending',
    report_date      datetime     not null default current_timestamp,
    foreign key (product_id) references products(product_id),
    foreign key (consumer_port_id) references consumer_port(port_id),
    foreign key (seller_port_id)   references seller_port(port_id)
);

-- lowercase-only before-insert trigger
drop trigger if exists before_insert_reported_products;
delimiter $$
create trigger before_insert_reported_products
before insert on reported_products
for each row
begin
    set new.status       = lower(new.status);
    set new.action_taken = lower(new.action_taken);
end $$
delimiter ;

-- lowercase-only before-update trigger
drop trigger if exists before_update_reported_products;
delimiter $$
create trigger before_update_reported_products
before update on reported_products
for each row
begin
    set new.status       = lower(new.status);
    set new.action_taken = lower(new.action_taken);
end $$
delimiter ;

-- AFTER INSERT Trigger: Automate action_taken and mark as solved
-- Procedure to add a new report
delimiter $$

drop procedure if exists add_reported_product $$
create procedure add_reported_product(
    in p_product_id int,
    in p_consumer_port_id varchar(50),
    in p_seller_port_id varchar(50),
    in p_issue_type enum('damaged','wrong_product','delay','still_not_received','missing')
)
begin
    declare v_action_taken enum('replacement', 'compensation', 'resend', 'refund', 'pending');

    -- check for duplicate report
    if exists (
        select 1 from reported_products
        where product_id = p_product_id
          and consumer_port_id = p_consumer_port_id
          and seller_port_id = p_seller_port_id
          and issue_type = p_issue_type
    ) then
        signal sqlstate '45000'
        set message_text = 'a report for this issue already exists by the same user on this product.';
    end if;

    -- assign action_taken based on issue_type
    if p_issue_type = 'damaged' then
        set v_action_taken = 'replacement';
    elseif p_issue_type = 'wrong_product' then
        set v_action_taken = 'resend';
    elseif p_issue_type = 'delay' then
        set v_action_taken = 'compensation';
    elseif p_issue_type = 'still_not_received' then
        set v_action_taken = 'refund';
    elseif p_issue_type = 'missing' then
        set v_action_taken = 'resend';
    else
        set v_action_taken = 'pending';
    end if;

    -- insert report with action_taken and status = solved
    insert into reported_products (
        product_id,
        consumer_port_id,
        seller_port_id,
        issue_type,
        action_taken,
        status
    ) values (
        p_product_id,
        p_consumer_port_id,
        p_seller_port_id,
        p_issue_type,
        v_action_taken,
        'solved'
    );

    -- return the inserted record
    select
        report_id,
        consumer_port_id as consumer_id,
        seller_port_id as seller_id,
        product_id,
        issue_type,
        action_taken,
        status,
        report_date
    from reported_products
    where report_id = last_insert_id();
end $$
delimiter ;

-- Procedure to update the issue type
delimiter $$
drop procedure if exists update_report_status $$
create procedure update_report_status(
    in p_report_id    int,
    in p_new_status   enum('solved','pending'),
    in p_action_taken enum('replacement','compensation','resend','refund','pending')
)
begin
    update reported_products
       set status       = p_new_status,
           action_taken = p_action_taken
     where report_id    = p_report_id;
end $$
delimiter ;
desc products;

-- Procedure to delete a report
delimiter $$
drop procedure if exists delete_reported_product $$
create procedure delete_reported_product(
    in p_report_id int
)
begin
    if not exists (select 1 from reported_products where report_id = p_report_id) then
        signal sqlstate '45000'
        set message_text = 'Error: No such report ID exists to delete';
    else
        delete from reported_products
        where report_id = p_report_id;
        select 'Report deleted successfully' as message;
    end if;
end $$
delimiter ;
-- --------------------------------------------------------------------- test case ---------------------------------------------------
CALL register_user('C001', 'pass@123', 'pass@123', 'consumer');
CALL register_user('C002', 'pass@456', 'pass@456', 'consumer');
CALL register_user('S001', 'sell@123', 'sell@123', 'seller');
CALL register_user('S002', 'sell@456', 'sell@456', 'seller');
CALL login_user('C001', 'pass@123', 'consumer'); 
CALL login_user('S001', 'sell@123', 'seller');    
CALL login_user('C001', 'pass@123', 'admin');  
CALL add_product('C123', 'Laptop', 10, 50000.00);
CALL add_product('S001', 'Mouse', 50, 599.00);
CALL list_products();
CALL update_product(1, null,'Laptop Pro', 800000.00);
CALL add_order('Laptop Pro', 'C001', 'S001', 2);
CALL get_orders();
CALL track_status(2);
CALL update_order_status(12, 'Shipped');
CALL update_order_status(12, 'Out for Delivery');
CALL update_order_status(28, 'Delivered');
CALL cancel_order(1, 'Changed mind');
CALL add_order('Mouse', 'C001', 'S001', 5);
CALL cancel_order(1, 'No longer needed');
CALL update_order_quantity(2, 5);
CALL add_order('Mouse', 'C001', 'S001', 1);
SELECT * FROM port_logs;
select * from seller_port;
select * from consumer_port;
SELECT * FROM product_logs;
SELECT * FROM products;
CALL get_orders();
CALL add_reported_product(9, 'minal@mm', 'minal@123', 'damaged');
CALL add_reported_product(2, 'C002', 'S001', 'missing');
call add_reported_product(9,'prachi@123','minal@123','damaged');
call add_reported_product(10,'prachi@123','minal@123','missing');
call update_report_issue(1, 'delay');
call delete_reported_product(3);
call get_seller_sales('S001');
select * from reported_products;
SELECT * FROM cart WHERE consumer_port_id = 'Minal@123';
drop trigger if exists after_insert_reported_products;
CALL get_seller_sales('S001');
CALL get_seller_sales_monthly('Minal@123');
CALL get_seller_sales_yearly('S001');
select * from product_logs order by log_id desc;
call get_user_details('Minal@123', 'consumer');
SELECT port_id, password, location FROM consumer_port WHERE port_id = 'prachi@123';
SELECT port_id, password FROM consumer_port WHERE port_id = 'prachi@123';
CALL get_user_details('prachi@123', 'consumer');
DESC cart;
CALL get_seller_sales_monthly_with_dates('Minal@123','2025-07-01','2025-07-31'     
);
CALL get_seller_sales_yearly_with_dates('Minal@123','2025-01-01','2025-12-31');
show tables;