# -*- encoding: utf-8 -*-
#
# Author:: Ryan Hass (<ryan@invalidchecksum.net>)
#
# Copyright (C) 2015, Ryan Hass
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'scaleway'
require 'kitchen'

module Kitchen
  module Driver
    # Scaleway Driver for Kitchen.
    #
    # @author Ryan Hass <ryan@invalidchecksum.net>
    class Scaleway < Kitchen::Driver::SSHBase

      default_config :username, 'root'
      default_config :port, '22'
      default_config(:image) { |driver| driver.default_image.id }
      default_config(:server_name) { |driver| driver.default_name }

      default_config :scaleway_org do
        ENV['SCALEWAY_ORG_TOKEN']
      end

      default_config :scaleway_access_token do
        ENV['SCALEWAY_ACCESS_TOKEN']
      end

      required_config :scaleway_org
      required_config :scaleway_access_token

      def create(state)
        client
        server = create_server

        state[:server_id] = server.id

        info("Scaleway instance <#{state[:server_id]}> created.")

        loop do
          info("Waiting for Public IP to become available...")
          sleep 8
          begin
            instance = ::Scaleway::Server.find(state[:server_id])
          rescue ::Scaleway::NotFound
            info('instance still not ready.')
          end

          break if instance && ! instance.public_ip.nil?
        end
        instance ||= ::Scaleway::Server.find(state[:server_id])

        state[:hostname] = instance.public_ip[:address]

        wait_for_sshd(state[:hostname]); print "(ssh ready)\n"
      end

      def destroy(state)
        client
        return if state[:server_id].nil?

        loop do
          begin
            instance = ::Scaleway::Server.find(state[:server_id])

            break if !instance
            if instance && instance.state != 'pending'
              volume = ::Scaleway::Server.find(state[:server_id]).image[:id]
              ::Scaleway::Server.terminate(state[:server_id])
              ::Scaleway::Image.destroy(volume)
              break
            end
          rescue ::Scaleway::APIError
            break if !instance
            if instance && instance.state == 'stopped'
              ::Scaleway::Server.destroy(state[:server_id])
              ::Scaleway::Image.destroy(state[:server_id].image[:id])
              raise ::Kitchen::Error
            end
          rescue ::Scaleway::NotFound
            instance = false
          end
        end

        info("Scaleway instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def default_image
        client
        ::Scaleway::Image.find_by_name(platform_to_slug_mapping.fetch(instance.platform.name,
                                                                      instance.platform.name))
      end

      # Generate what should be a unique server name up to 63 total chars
      # Base name:    15
      # Username:     15
      # Hostname:     23
      # Random string: 7
      # Separators:    3
      # ================
      # Total:        63
      def default_name
        [
          @instance.name.gsub(/\W/, '')[0..14],
          Etc.getlogin.gsub(/\W/, '')[0..14],
          Socket.gethostname.gsub(/\W/, '')[0..22],
          Array.new(7) { rand(36).to_s(36) }.join
        ].join('-').gsub(/_/, '-')
      end

      def client
        ::Scaleway.organization = config[:scaleway_org]
        ::Scaleway.token = config[:scaleway_access_token]
      end

      def create_server
        client

        instance = ::Scaleway::Server.create(
          {
            name: config[:server_name],
            image: config[:image]
          }
        )

        ::Scaleway::Server.power_on(instance.id)

        instance
      end

      def platform_to_slug_mapping
        {
          'debian-7.0'    => 'Debian Wheezy (7.8)',
          'debian-8.1'    => 'Debian Jessie (8.1)',
          'fedora-22'     => 'Fedora 22',
          'opensuse-13.2' => 'openSUSE 13.2',
          'ubuntu-12.04'  => 'Ubuntu Precise (12.04)',
          'ubuntu-14.04'  => 'Ubuntu Trusty (14.04 LTS)',
          'ubuntu-14.10'  => 'Ubuntu Utopic (14.10 EOL)',
          'ubuntu-15.04'  => 'Ubuntu Vivid (15.04 latest)'
        }
      end

    end
  end
end
