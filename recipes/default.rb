#
# Cookbook Name:: chef_task_2
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'yum::default'

# install mysql
package 'mysql-server' do
  action :install
end

# start mysql server
service 'mysqld' do
  action :start
end

# deleting test database
execute 'delete-test-db' do
  user "root"
  command "mysql -e 'show databases' | grep -v Database | grep -v mysql| grep -v information_schema | gawk '{print 'drop database ' $1 ';'}' | mysql -uroot > /dev/null"
end

# creating stage_db
execute 'create-stage_db' do
  user "root"
  command "mysql -e 'create database #{node['chef_task_2']['db_stage']}'"
end

# creating prod db
execute 'create-prod_db' do
  user "root"
  command "mysql -e 'create database #{node['chef_task_2']['db_prod']}'"
end

# creating user service_stage
execute 'create-user-service_stage' do
  user "root"
  command "mysql -e \"create user '#{node['chef_task_2']['user_stage']}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -e \"grant select,insert,update,delete,create,drop on stage_db.* to '#{node['chef_task_2']['user_stage']}'@'%'\" "
end

# creating user service_prod
execute 'create-user-service_prod' do
  user "root"
  command "mysql -e \"create user '#{node['chef_task_2']['user_prod']}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -e \"grant select,insert,update,delete,create,drop on prod_db.* to '#{node['chef_task_2']['user_prod']}'@'%'\" "
end
