#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
if node["mysql"]["type"] == "mysql"
  include_recipe "mysql::client"
else
  Chef::Log.info("MySQL type is not  mysql")
end

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

Chef::Log.info("--------- MySQL User ---------")
node[:mysql][:apps].each do |app|
  Chef::Log.info("MySQL database from #{app}")
  search(:apps, "id:#{app} AND status:enable") do |a|
    a[:databases].each do |n, db|
      Chef::Log.info(">>>>>> database: #{db[:database]}")

      mysql_database db[:database] do
        connection mysql_connection_info
        action :create
      end

      mysql_database_user "#{db[:username]}" do
        connection mysql_connection_info
        password db[:password]
        database_name db[:database]
        host '%'
        #privileges [:select,:update,:insert]
        privileges [:all]
        action :grant
      end
    end
  end
end
