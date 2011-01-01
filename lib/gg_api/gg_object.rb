module GGApi
  class GGObject
    def initialize(attributes)
      if attributes.kind_of?(Hash)
        attributes.each do |k, v|
          instance_eval %{
            def #{k}
              @#{k}
            end
            def #{k}=(val)
              #{k} = val
            end
          }
          instance_variable_set(:"@#{k}", v)
        end
      end
    end
  end
end
