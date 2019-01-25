require 'json'
require 'open3'

module ProspectusGolang
  ##
  # Helper for automatically adding dependency status check
  class Deps < Module
    def extended(other) # rubocop:disable Metrics/MethodLength
      dep_list = parse_deps
      other.deps do
        dep_list.each do |dep_name, tag, hash|
          item do
            name 'dep::' + dep_name

            expected do
              hash ? github_hash : github_tag
              repo dep_name
              filter(/^v\d+\.\d+\.\d+$/) unless hash
            end

            actual do
              static
              set(hash || tag)
            end
          end
        end
      end
    end

    private

    def parse_deps
      list_deps.map do |x|
        name, version = x.split('@')
        tag, _, hash = version.split('-')
        tag.sub!('+incompatible', '')
        [clean(name), tag, hash ? hash[0..6] : nil]
      end
    end

    def list_deps
      o, e, s = Open3.capture3('go mod graph')
      raise("Command failed: #{e}") unless s.success?
      name = o.split.first
      o.split("\n").grep(/^#{name}/).map(&:split).map(&:last)
    end

    def clean(name)
      case name
      when %r{^github\.com/}
        return name.split('/', 2).last
      when %r{^golang\.org/x/}
        return "golang/#{name.split('/').last}"
      when /^gopkg\.in/
        return name.match(%r{^gopkg\.in/(.*?)(\.v\d+)?$})[1]
      end
      raise "Name not parsed properly: #{name}"
    end
  end
end
