#
# Cookbook Name:: chef_task_2
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'yum::default'
mysql_bag = search(:admins, "id:mysql").first

# MySQL creds
mysql_user = mysql_bag['user']
mysql_passwd = mysql_bag['pass']


# install mysql
package 'mysql-server' do
  action :install
end

# start mysql server
service 'mysqld' do
  action [:enable, :restart]
end

execute 'mysql_root_pass' do
  sensitive true
  command "mysql -u#{mysql_user} -e \"set password for 'root'@'localhost' = password('#{mysql_passwd}')\" "
end

# deleting test database
execute 'delete-test-db' do
  #sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'show databases' | grep -v Database | grep -v mysql| grep -v information_schema | gawk '{print \"drop database \" $1 \";\"}' | mysql -p#{mysql_passwd}"
end

# creating stage_db
execute 'create-stage_db' do
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'create database #{node['chef_task_2']['db_stage']}'"
end

# creating prod db
execute 'create-prod_db' do
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e 'create database #{node['chef_task_2']['db_prod']}'"
end

# creating user service_stage
execute 'create-user-stage' do
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"create user '#{node['chef_task_2']['user_stage']}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"grant select,insert,update,delete,create,drop on #{node['chef_task_2']['db_stage']}.* to '#{node['chef_task_2']['user_stage']}'@'%'\" "
end

# creating user service_prod
execute 'create-user-prod' do
  sensitive true
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"create user '#{node['chef_task_2']['user_prod']}'@'%' IDENTIFIED BY 'password'\" "
  command "mysql -u#{mysql_user} -p#{mysql_passwd} -e \"grant select,insert,update,delete,create,drop on #{node['chef_task_2']['db_prod']}.* to '#{node['chef_task_2']['user_prod']}'@'%'\" "
end
