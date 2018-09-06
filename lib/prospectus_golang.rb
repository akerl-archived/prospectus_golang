require 'json'
require 'open3'

module ProspectusGolang
  ##
  # Helper for automatically adding dependency status check
  class Deps < Module
    def extended(other) # rubocop:disable Metrics/MethodLength
      dep_list = parse_deps
      other.deps do
        dep_list.each do |dep_name, current, latest|
          item do
            name 'dep::' + dep_name

            expected do
              static
              set latest
            end

            actual do
              static
              set current
            end
          end
        end
      end
    end

    private

    def parse_deps
      call_dep.map { |x| [x['ProjectRoot'], *parse_version(x)] }
    end

    def call_dep
      o, e, s = Open3.capture3('STATUS_FLAGS=-json make -s status')
      raise("Command failed: #{e}") unless s.success?
      JSON.parse(o)
    end

    def parse_version(object)
      latest = object['Latest']
      return [object['Version'], latest] unless object['Version'] =~ /^branch /
      [object['Revision'][0..8], latest[0..8]]
    end
  end
end
