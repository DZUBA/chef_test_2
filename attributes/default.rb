#
# Cookbook Name:: chef_task_2
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Database name
default['chef_task_2']['db_prod'] = 'prod_db'
default['chef_task_2']['db_stage'] = 'stage_db'

# Database users
default['chef_task_2']['user_prod'] = 'service_prod'
default['chef_task_2']['user_stage'] = 'service_stage'
