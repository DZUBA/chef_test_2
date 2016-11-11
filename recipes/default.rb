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
  command 'mysql -uroot -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema | gawk \'{print "drop database " $1 ";"}\' | mysql -uroot > /dev/null'
end

# creating stage_db
execute 'create-stage_db' do
  command 'mysql -uroot -e "create database stage_db"'
end

# creating prod db
execute 'create-prod_db' do
  command 'mysql -uroot -e "create database prod_db"'
end

# creating user service_stage

# creating user service_prod
