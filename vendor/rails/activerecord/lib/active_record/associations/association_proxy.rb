module ActiveRecord
  module Associations
    class AssociationProxy #:nodoc:
      alias_method :proxy_respond_to?, :respond_to?
      alias_method :proxy_extend, :extend
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?|^proxy_respond_to\?|^proxy_extend|^send)/ }

      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        proxy_extend(reflection.options[:extend]) if reflection.options[:extend]
        reset
      end
      
      def respond_to?(symbol, include_priv = false)
        proxy_respond_to?(symbol, include_priv) || (load_target && @target.respond_to?(symbol, include_priv))
      end

      # Explicitly proxy === because the instance method removal above
      # doesn't catch it.
      def ===(other)
        load_target
        other === @target
      end

      def reset
        @target = nil
        @loaded = false
      end

      def reload
        reset
        load_target
      end

      def loaded?
        @loaded
      end
      
      def loaded
        @loaded = true
      end
      
      def target
        @target
      end
      
      def target=(target)
        @target = target
        loaded
      end
      
      protected
        def dependent?
          @reflection.options[:dependent] || false
        end
        
        def quoted_record_ids(records)
          records.map { |record| record.quoted_id }.join(',')
        end

        def interpolate_sql_options!(options, *keys)
          keys.each { |key| options[key] &&= interpolate_sql(options[key]) }
        end

        def interpolate_sql(sql, record = nil)
          @owner.send(:interpolate_sql, sql, record)
        end

        def sanitize_sql(sql)
          @reflection.klass.send(:sanitize_sql, sql)
        end

        def extract_options_from_args!(args)
          @owner.send(:extract_options_from_args!, args)
        end

        def set_belongs_to_association_for(record)
          if @reflection.options[:as]
            record["#{@reflection.options[:as]}_id"]   = @owner.id unless @owner.new_record?
            record["#{@reflection.options[:as]}_type"] = ActiveRecord::Base.send(:class_name_of_active_record_descendant, @owner.class).to_s
          else
            record[@reflection.primary_key_name] = @owner.id unless @owner.new_record?
          end
        end

        def merge_options_from_reflection!(options)
          options.reverse_merge!(
            :group   => @reflection.options[:group],
            :limit   => @reflection.options[:limit],
            :offset  => @reflection.options[:offset],
            :joins   => @reflection.options[:joins],
            :include => @reflection.options[:include],
            :select  => @reflection.options[:select]
          )
        end
        
      private
        def method_missing(method, *args, &block)
          load_target
          @target.send(method, *args, &block)
        end

        def load_target
          if !@owner.new_record? || foreign_key_present
            begin
              @target = find_target if !loaded?
            rescue ActiveRecord::RecordNotFound
              reset
            end
          end

          loaded if target
          target
        end

        # Can be overwritten by associations that might have the foreign key available for an association without
        # having the object itself (and still being a new record). Currently, only belongs_to present this scenario.
        def foreign_key_present
          false
        end

        def raise_on_type_mismatch(record)
          unless record.is_a?(@reflection.klass)
            raise ActiveRecord::AssociationTypeMismatch, "#{@reflection.class_name} expected, got #{record.class}"
          end
        end
    end
  end
end
