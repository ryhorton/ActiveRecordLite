class AttrAccessorObject
  def self.my_attr_accessor(*names)

    names.each do |name|

      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

  end

  # attr_accessor :color, :age
  #
  # def color
  #   @color
  # end
  #
  # def color=(value)
  #   @color = value
  # end
end
