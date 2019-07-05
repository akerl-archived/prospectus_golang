require 'json'
require 'open3'

module ProspectusGolang
  ##
  # Helper for automatically adding dependency status check
  class Deps < Module
    def initialize(params = {})
      @options = params
    end

    def extended(other) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      dep_list = parse_deps
      other.deps do
        dep_list.each do |dep_name, api, tag, hash|
          item do
            name 'dep::' + dep_name

            expected do
              hash ? github_hash : github_tag
              repo dep_name
              endpoint(api) if api
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
        dep_name, api = clean(name)
        [dep_name, api, tag, hash ? hash[0..6] : nil]
      end
    end

    def list_deps
      o, e, s = Open3.capture3('go mod graph')
      raise("Command failed: #{e}") unless s.success?
      name = o.split.first
      o.split("\n").grep(/^#{name}/).map(&:split).map(&:last)
    end

    def clean(name)
      name = name.sub(%r{/v\d+$}, '')
      case name
      when %r{^golang\.org/x/}
        return "golang/#{name.split('/').last}", nil
      when /^gopkg\.in/
        path = name.match(%r{^gopkg\.in/(.*?)(\.v\d+)?$})[1]
        return path.include?('/') ? path : "go-#{path}/#{path}", nil
      end
      github_clean(name) || raise("Name not parsed properly: #{name}")
    end

    def github_map
      @github_map ||= { 'github.com' => nil }.merge(@options[:github_map] || {})
    end

    def github_clean(name)
      github_map.each do |web, api|
        next unless name.start_with? web
        return name.split('/')[-2..-1].join('/'), api
      end
      nil
    end
  end
end
