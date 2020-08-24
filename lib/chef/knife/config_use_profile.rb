#
# Copyright:: Copyright (c) 2018, Noah Kantrowitz
# License:: Apache License, Version 2.0
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
#

require_relative "../knife"

class Chef
  class Knife
    class ConfigUseProfile < Knife
      banner "knife config use-profile PROFILE"

      deps do
        require "fileutils" unless defined?(FileUtils)
      end

      # Disable normal config loading since this shouldn't fail if the profile
      # doesn't exist of the config is otherwise corrupted.
      def configure_chef
        apply_computed_config
      end

      def run
        credentials_data = self.class.config_loader.parse_credentials
        context_file = ChefConfig::PathHelper.home(".chef", "context").freeze
        profile = @name_args[0]&.strip
        if profile.nil? || profile.empty?
          show_usage
          ui.fatal("You must specify a profile")
          exit 1
        end

        if credentials_data.nil? || credentials_data.empty?
          ui.fatal("No profiles found")
          exit 1
        end

        if credentials_data[profile].nil?
          raise ChefConfig::ConfigurationError, "Profile #{profile} doesn't exist."
        else
          # Ensure the .chef/ folder exists.
          FileUtils.mkdir_p(File.dirname(context_file))
          IO.write(context_file, "#{profile}\n")
          ui.msg("Set default profile to #{profile}")
        end
      end

    end
  end
end
