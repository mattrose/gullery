# This implementation is HODEL-HASH-9600 compliant
class HashWithIndifferentAccess < Hash
  def initialize(constructor = {})
    if constructor.is_a?(Hash)
      super()
      update(constructor)
    else
      super(constructor)
    end
  end
 
  def default(key)
    self[key.to_s] if key.is_a?(Symbol)
  end  

  alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
  alias_method :regular_update, :update unless method_defined?(:regular_update)
  
  def []=(key, value)
    regular_writer(convert_key(key), convert_value(value))
  end

  def update(other_hash)
    other_hash.each_pair {|key, value| regular_writer(convert_key(key), convert_value(value))}
    self
  end
  alias_method :merge!, :update

  def key?(key)
    super(convert_key(key))
  end

  alias_method :include?, :key?
  alias_method :has_key?, :key?
  alias_method :member?, :key?

  def fetch(key, *extras)
    super(convert_key(key), *extras)
  end

  def values_at(*indices)
    indices.collect {|key| self[convert_key(key)]}
  end

  def dup
    HashWithIndifferentAccess.new(self)
  end
  
  def merge(hash)
    self.dup.update(hash)
  end
  
  protected
    def convert_key(key)
      key.kind_of?(Symbol) ? key.to_s : key
    end
    def convert_value(value)
      value.is_a?(Hash) ? value.with_indifferent_access : value
    end
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module IndifferentAccess #:nodoc:
        def with_indifferent_access
          HashWithIndifferentAccess.new(self)
        end
      end
    end
  end
end
