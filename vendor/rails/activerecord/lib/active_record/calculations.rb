module ActiveRecord
  module Calculations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Count operates using three different approaches. 
      #
      # * Count all: By not passing any parameters to count, it will return a count of all the rows for the model.
      # * Count by conditions or joins: For backwards compatibility, you can pass in +conditions+ and +joins+ as individual parameters.
      # * Count using options will find the row count matched by the options used.
      #
      # The last approach, count using options, accepts an option hash as the only parameter. The options are:
      #
      # * <tt>:conditions</tt>: An SQL fragment like "administrator = 1" or [ "user_name = ?", username ]. See conditions in the intro.
      # * <tt>:joins</tt>: An SQL fragment for additional joins like "LEFT JOIN comments ON comments.post_id = id". (Rarely needed).
      #   The records will be returned read-only since they will have attributes that do not correspond to the table's columns.
      # * <tt>:include</tt>: Named associations that should be loaded alongside using LEFT OUTER JOINs. The symbols named refer
      #   to already defined associations. When using named associations count returns the number DISTINCT items for the model you're counting.
      #   See eager loading under Associations.
      #
      # Examples for counting all:
      #   Person.count         # returns the total count of all people
      #
      # Examples for count by +conditions+ and +joins+ (for backwards compatibility):
      #   Person.count("age > 26")  # returns the number of people older than 26
      #   Person.find("age > 26 AND job.salary > 60000", "LEFT JOIN jobs on jobs.person_id = person.id") # returns the total number of rows matching the conditions and joins fetched by SELECT COUNT(*).
      #
      # Examples for count with options:
      #   Person.count(:conditions => "age > 26")
      #   Person.count(:conditions => "age > 26 AND job.salary > 60000", :include => :job) # because of the named association, it finds the DISTINCT count using LEFT OUTER JOIN.
      #   Person.count(:conditions => "age > 26 AND job.salary > 60000", :joins => "LEFT JOIN jobs on jobs.person_id = person.id") # finds the number of rows matching the conditions and joins. 
      #   Person.count('id', :conditions => "age > 26") # Performs a COUNT(id)
      #   Person.count(:all, :conditions => "age > 26") # Performs a COUNT(*) (:all is an alias for '*')
      #
      # Note: Person.count(:all) will not work because it will use :all as the condition.  Use Person.count instead.
      def count(*args)
        options    = {}
        column_name = :all
        
        #For backwards compatibility, we need to handle both count(conditions=nil, joins=nil) or count(options={}).
        if args.size >= 0 and args.size <= 2
          if args.first.is_a?(Hash)
            options = args.first
            #should we verify the options hash???
          elsif args[1].is_a?(Hash)
            column_name = args.first
            options    = args[1]
          else
            # Handle legacy paramter options: def count(conditions=nil, joins=nil) 
            options.merge!(:conditions => args[0]) if args.length > 0
            options.merge!(:joins => args[1]) if args.length > 1
          end
        else
          raise(ArgumentError, "Unexpected parameters passed to count(*args): expected either count(conditions=nil, joins=nil) or count(options={})")
        end
        
        column_name = options[:select] if options[:select]
        options[:include] ? count_with_associations(options) : calculate(:count, column_name, options)
      end

      # Calculates average value on a given column.  The value is returned as a float.  See #calculate for examples with options.
      #
      #   Person.average('age')
      def average(column_name, options = {})
        calculate(:avg, column_name, options)
      end

      # Calculates the minimum value on a given column.  The value is returned with the same data type of the column..  See #calculate for examples with options.
      #
      #   Person.minimum('age')
      def minimum(column_name, options = {})
        calculate(:min, column_name, options)
      end

      # Calculates the maximum value on a given column.  The value is returned with the same data type of the column..  See #calculate for examples with options.
      #
      #   Person.maximum('age')
      def maximum(column_name, options = {})
        calculate(:max, column_name, options)
      end

      # Calculates the sum value on a given column.  The value is returned with the same data type of the column..  See #calculate for examples with options.
      #
      #   Person.maximum('age')
      def sum(column_name, options = {})
        calculate(:sum, column_name, options)
      end

      # This calculates aggregate values in the given column:  Methods for count, sum, average, minimum, and maximum have been added as shortcuts.
      # Options such as :conditions, :order, :group, :having, and :joins can be passed to customize the query.  
      #
      # There are two basic forms of output:
      #   * Single aggregate value: The single value is type cast to Fixnum for COUNT, Float for AVG, and the given column's type for everything else.
      #   * Grouped values: This returns an ordered hash of the values and groups them by the :group option.  It takes either a column name, or the name 
      #     of a belongs_to association.
      #
      #       values = Person.maximum(:age, :group => 'last_name')
      #       puts values["Drake"]
      #       => 43
      #
      #       drake  = Family.find_by_last_name('Drake')
      #       values = Person.maximum(:age, :group => :family) # Person belongs_to :family
      #       puts values[drake]
      #       => 43
      #
      #       values.each do |family, max_age|
      #       ...
      #       end
      #
      # Examples:
      #   Person.calculate(:count, :all) # The same as Person.count
      #   Person.average(:age) # SELECT AVG(age) FROM people...
      #   Person.minimum(:age, :conditions => ['last_name != ?', 'Drake']) # Selects the minimum age for everyone with a last name other than 'Drake'
      #   Person.minimum(:age, :having => 'min(age) > 17', :group => :last_name) # Selects the minimum age for any family without any minors
      def calculate(operation, column_name, options = {})
        column_name     = '*' if column_name == :all
        column          = columns.detect { |c| c.name.to_s == column_name.to_s }
        aggregate       = select_aggregate(operation, column_name, options)
        aggregate_alias = column_alias_for(operation, column_name)
        if options[:group]
          execute_grouped_calculation(operation, column_name, column, aggregate, aggregate_alias, options)
        else
          execute_simple_calculation(operation, column_name, column, aggregate, aggregate_alias, options)
        end
      end

      protected
      def construct_calculation_sql(aggregate, aggregate_alias, options)
        sql  = ["SELECT #{aggregate} AS #{aggregate_alias}"]
        sql << ", #{options[:group_field]} AS #{options[:group_alias]}" if options[:group]
        sql << " FROM #{table_name} "
        add_joins!(sql, options)
        add_conditions!(sql, options[:conditions])
        sql << " GROUP BY #{options[:group_field]}" if options[:group]
        sql << " HAVING #{options[:having]}" if options[:group] && options[:having]
        sql.join
      end

      def execute_simple_calculation(operation, column_name, column, aggregate, aggregate_alias, options)
        value     = connection.select_value(construct_calculation_sql(aggregate, aggregate_alias, options))
        type_cast_calculated_value(value, column, operation)
      end

      def execute_grouped_calculation(operation, column_name, column, aggregate, aggregate_alias, options)
        group_attr      = options[:group].to_s
        association     = reflect_on_association(group_attr.to_sym)
        associated      = association && association.macro == :belongs_to # only count belongs_to associations
        group_field     = (associated ? "#{options[:group]}_id" : options[:group]).to_s
        group_alias     = column_alias_for(group_field)
        sql             = construct_calculation_sql(aggregate, aggregate_alias, options.merge(:group_field => group_field, :group_alias => group_alias))
        calculated_data = connection.select_all(sql)

        if association
          key_ids     = calculated_data.collect { |row| row[group_alias] }
          key_records = ActiveRecord::Base.send(:class_of_active_record_descendant, association.klass).find(key_ids)
          key_records = key_records.inject({}) { |hsh, r| hsh.merge(r.id => r) }
        end

        calculated_data.inject(OrderedHash.new) do |all, row|
          key   = associated ? key_records[row[group_alias].to_i] : row[group_alias]
          value = row[aggregate_alias]
          all << [key, type_cast_calculated_value(value, column, operation)]
        end
      end

      private
      def select_aggregate(operation, column_name, options)
        "#{operation}(#{'DISTINCT ' if options[:distinct]}#{column_name})"
      end

      # converts a given key to the value that the database adapter returns as
      #
      #   users.id #=> users_id
      #   sum(id) #=> sum_id
      #   count(distinct users.id) #=> count_distinct_users_id
      #   count(*) #=> count_all
      def column_alias_for(*keys)
        keys.join(' ').downcase.gsub(/\*/, 'all').gsub(/\W+/, ' ').strip.gsub(/ +/, '_')
      end

      def type_cast_calculated_value(value, column, operation)
        operation = operation.to_s.downcase
        case operation
          when 'count' then value.to_i
          when 'avg'   then value.to_f
          else column ? column.type_cast(value) : value
        end
      end
    end
  end
end