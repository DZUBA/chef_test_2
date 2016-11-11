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

execute 'delete-test-db' do
  command 'mysql -uroot -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema | gawk \'{print "drop database " $1 ";"}\' | mysql -uroot > /dev/null'
end
