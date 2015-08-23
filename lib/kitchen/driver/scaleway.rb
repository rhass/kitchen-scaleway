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

        # A new instance cannot be destroyed before it is powered off.
        # Retry stopping the instance as long as its status is not "stopped"

        loop do
          instance = ::Scaleway::Server.find(state[:server_id])

          break if instance.state == 'stopped'
          if instance.state != 'pending'
            ::Scaleway::Server.power_off(state[:server_id])
            break
          end

          info("Waiting on Scaleway instance <#{state[:server_id]}> to be stopped to destroy it, retrying in 8 seconds")
          sleep 8
        end

        loop do
          instance = ::Scaleway::Server.find(state[:server_id])

          break if !instance
            if instance.state != 'pending'
              ::Scaleway::Server.terminate(state[:server_id])
              break
            end
        end

        info("Scaleway instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def default_image
        client
        ::Scaleway::Image.find_by_name(@instance.platform.name)
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
        ::Scaleway.organization = '8c939c05-188b-46b2-abdc-bc0b16b7e175'
        ::Scaleway.token = 'ab497fa3-8f06-4f1e-a6e4-5f93652776f2'
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

    end
  end
end
