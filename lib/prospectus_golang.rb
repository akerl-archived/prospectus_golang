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
    end
  end
end
