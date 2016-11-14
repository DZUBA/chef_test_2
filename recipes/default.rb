#
# Cookbook Name:: chef_task_2
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'yum::default'

admins = data_bag('admins')
databases = data_bag('databases')

mysql_bag = data_bag_item('admins', 'mysql')
stage_bag = data_bag_item('databases', 'stage')
prod_bag = data_bag_item('databases', 'prod')

# MySQL creds
mysql_user = mysql_bag['user']
mysql_passwd = mysql_bag['pass']
stage_user = stage_bag['db_user']
stage_db = stage_bag['db_name']
prod_user = prod_bag['db_user']
prod_db = prod_bag['db_name']

# install mysql
package 'mysql-server' do
  not_if 'yum list installed | grep mysql-server'
  action :install
  notifies :start, 'service[mysqld]', :immediately
  notifies :run, 'execute[mysql_root_pass]'
  notifies :run, 'execute[delete-test-db]'
  notifies :run, 'execute[create-stage_db]'
  notifies :run, 'execute[create-prod_db]'
  notifies :run, 'execute[create-user-prod]'
  notifies :run, 'execute[create-user-stage]'
end

# start mysql server
service 'mysqld' do
  action :nothing
end

execute 'mysql_root_pass' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -e \"set password for 'root'@'localhost' = password('#{mysql_passwd}')\" "
end

# deleting test database
execute 'delete-test-db' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'show databases' | grep -v Database | grep -v mysql| grep -v information_schema | gawk '{print \"drop database \" $1 \";\"}' | mysql -p#{mysql_passwd}"
end

# creating stage_db
execute 'create-stage_db' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'create database #{stage_db}'"
end

# creating prod db
execute 'create-prod_db' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'create database #{prod_db}'"
end

# creating user service_stage
execute 'create-user-stage' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"create user '#{stage_user}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"grant select,insert,update,delete,create,drop on #{stage_db}.* to '#{stage_user}'@'%'\" "
end

# creating user service_prod
execute 'create-user-prod' do
  action :nothing
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"create user '#{prod_user}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"grant select,insert,update,delete,create,drop on #{prod_db}.* to '#{prod_user}'@'%'\" "
end

# importing stage_db schema
execute 'stage_import' do
  sensitive true
  command "mysql -p#{mysql_passwd} -u#{mysql_user} -D#{stage_db} < /tmp/schema.sql"
  action :nothing
end

# importing prod_db schema
execute 'prod_import' do
  sensitive true
  command "mysql -p#{mysql_passwd} -u#{mysql_user} -D#{prod_db} < /tmp/schema.sql"
  action :nothing
end

# import schema file
cookbook_file '/tmp/schema.sql' do
  source 'schema.sql'
  notifies :run, 'execute[stage_import]', :delayed
  notifies :run, 'execute[prod_import]', :delayed
end
