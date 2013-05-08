# recipes/default.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2013 Simple Finance Technology Corporation
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
# Configures the Riemann server

include_recipe 'java::default'
include_recipe 'rbenv::system'
include_recipe 'runit::default'

rbenv_global '1.9.3-p374'

user node[:riemann][:user][:name] do
  home node[:riemann][:user][:home]
  shell '/bin/bash'
  system true
end

directory node[:riemann][:user][:home] do
  owner node[:riemann][:user][:name]
  group node[:riemann][:user][:name]
  action :create
end

directory '/var/log/riemann/' do
  mode 00755
  owner node[:riemann][:user][:name]
  group node[:riemann][:user][:name]
  action :create
end

remote_file ::File.join(Chef::Config[:file_cache_path], node[:riemann][:package]) do
  source node[:riemann][:package_url]
  mode 00644
  action :create_if_missing
end

package ::File.join(Chef::Config[:file_cache_path], node[:riemann][:package]) do
  provider Chef::Provider::Package::Dpkg
  action :install
end

runit_service 'riemann' do
  supports :restart => true
  action [:enable, :start]
end

include_recipe 'riemann::utilities'
include_recipe 'riemann::dashboard'

