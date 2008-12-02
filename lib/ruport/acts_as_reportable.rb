# Ruport : Extensible Reporting System                                
#
# acts_as_reportable.rb provides ActiveRecord integration for Ruport.
#     
# Originally created by Dudley Flanders, 2006
# Revised and updated by Michael Milner, 2007     
# Copyright (C) 2006-2007 Dudley Flanders / Michael Milner, All Rights Reserved.  
#
# This is free software distributed under the same terms as Ruby 1.8
# See LICENSE and COPYING for details.   
#
require "ruport"
Ruport.quiet { require "active_record" }

module Ruport

  # === Overview
  # 
  # This module is designed to allow an ActiveRecord model to be converted to
  # Ruport's data structures.  If ActiveRecord is available when Ruport is
  # loaded, this module will be automatically mixed into ActiveRecord::Base.
  #
  # Add the acts_as_reportable call to the model class that you want to
  # integrate with Ruport:
  #
  #   class Book < ActiveRecord::Base
  #     acts_as_reportable
  #     belongs_to :author
  #   end
  #
  # Then you can use the <tt>report_table</tt> method to get data from the
  # model using ActiveRecord.
  #
  #   Book.report_table(:all, :include => :author)
  #
  module Reportable

    def self.included(base) #:nodoc:
      base.extend ClassMethods  
    end

    # === Overview
    # 
    # This module contains class methods that will automatically be available
    # to ActiveRecord models.
    #
    module ClassMethods 

      # In the ActiveRecord model you wish to integrate with Ruport, add the 
      # following line just below the class definition:
      #
      #   acts_as_reportable
      #
      # Available options:
      #
      # <b><tt>:only</tt></b>::     an attribute name or array of attribute
      #                             names to include in the results, other
      #                             attributes will be excuded.
      # <b><tt>:except</tt></b>::   an attribute name or array of attribute
      #                             names to exclude from the results.
      # <b><tt>:methods</tt></b>::  a method name or array of method names
      #                             whose result(s) will be included in the
      #                             table.
      # <b><tt>:include</tt></b>::  an associated model or array of associated
      #                             models to include in the results.
      #
      # Example:
      # 
      #   class Book < ActiveRecord::Base
      #     acts_as_reportable, :only => 'title', :include => :author
      #   end
      #
      def acts_as_reportable(options = {})
        cattr_accessor :aar_options, :aar_columns

        self.aar_options = options

        include Ruport::Reportable::InstanceMethods
        extend Ruport::Reportable::SingletonMethods
      end
    end

    # === Overview
    # 
    # This module contains methods that will be made available as singleton
    # class methods to any ActiveRecord model that calls
    # <tt>acts_as_reportable</tt>.
    #
    module SingletonMethods

      # Creates a Ruport::Data::Table from an ActiveRecord find. Takes 
      # parameters just like a regular find.
      #
      # Additional options include:
      #
      # <b><tt>:only</tt></b>::     An attribute name or array of attribute
      #                             names to include in the results, other
      #                             attributes will be excuded.
      # <b><tt>:except</tt></b>::   An attribute name or array of attribute
      #                             names to exclude from the results.
      # <b><tt>:methods</tt></b>::  A method name or array of method names
      #                             whose result(s) will be included in the
      #                             table.
      # <b><tt>:include</tt></b>::  An associated model or array of associated
      #                             models to include in the results.
      # <b><tt>:filters</tt></b>::  A proc or array of procs that set up
      #                             conditions to filter the data being added
      #                             to the table.
      # <b><tt>:transforms</tt></b>::  A proc or array of procs that perform
      #                                transformations on the data being added
      #                                to the table.
      # <b><tt>:record_class</tt></b>::  Specify the class of the table's
      #                                  records.
      # <b><tt>:eager_loading</tt></b>::  Set to false if you don't want to
      #                                   eager load included associations.
      #
      # The :only, :except, :methods, and :include options may also be passed
      # to the :include option in order to specify the output for any
      # associated models. In this case, the :include option must be a hash,
      # where the keys are the names of the associations and the values
      # are hashes of options.
      #
      # Any options passed to report_table will disable the options set by
      # the acts_as_reportable class method.
      #
      # Example:
      # 
      #   class Book < ActiveRecord::Base
      #     belongs_to :author
      #     acts_as_reportable
      #   end
      #
      #   Book.report_table(:all, :only => ['title'],
      #     :include => { :author => { :only => 'name' } }).as(:html)
      #
      # Returns:
      #
      # an html version of the table with two columns, title from 
      # the book, and name from the associated author.
      #
      # Example:
      # 
      #   Book.report_table(:all, :include => :author).as(:html)
      #
      # Returns:
      #
      # an html version of the table with all columns from books and authors.
      #
      # Note: column names for attributes of included models will be qualified
      # with the name of the association. 
      #
      def report_table(number = :all, options = {})
        only = options.delete(:only)
        except = options.delete(:except)
        methods = options.delete(:methods)
        includes = options.delete(:include)
        filters = options.delete(:filters) 
        transforms = options.delete(:transforms)
        record_class = options.delete(:record_class) || Ruport::Data::Record

        unless options.delete(:eager_loading) == false
          options[:include] = get_include_for_find(includes)
        end

        data = [*find(number, options)]
        data.compact!
        columns = []
        data = data.map do |r|
          row, new_cols = r.reportable_data(:include => includes,
            :only => only,
            :except => except,
            :methods => methods)
          columns |= new_cols
          row
        end
        data.flatten!

        table = Ruport::Data::Table.new(:data => data,
                                        :column_names => columns,
                                        :record_class => record_class,
                                        :filters => filters,
                                        :transforms => transforms)
      end

      # Creates a Ruport::Data::Table from an ActiveRecord find_by_sql.
      #
      # Additional options include:
      #
      # <b><tt>:filters</tt></b>::  A proc or array of procs that set up
      #                             conditions to filter the data being added
      #                             to the table.
      # <b><tt>:transforms</tt></b>::  A proc or array of procs that perform
      #                                transformations on the data being added
      #                                to the table.
      # <b><tt>:record_class</tt></b>::  Specify the class of the table's
      #                                  records.
      #
      # Example:
      # 
      #   class Book < ActiveRecord::Base
      #     belongs_to :author
      #     acts_as_reportable
      #   end
      #
      #   Book.report_table_by_sql("SELECT * FROM books")
      #
      def report_table_by_sql(sql, options = {})
        record_class = options.delete(:record_class) || Ruport::Data::Record
        filters = options.delete(:filters) 
        transforms = options.delete(:transforms)

        data = find_by_sql(sql)
        columns = []
        data = data.map do |r|
          table = r.reportable_data
          columns |= table[1]
          table[0]
        end
        data.flatten!

        table = Ruport::Data::Table.new(:data => data,
                                        :column_names => columns,
                                        :record_class => record_class,
                                        :filters => filters,
                                        :transforms => transforms)
      end

      private

      def get_include_for_find(report_option)
        includes = report_option.blank? ? aar_options[:include] : report_option
        if includes.is_a?(Hash)
          result = {}
          includes.each do |k,v|
            if v.empty? || !v[:include]
              result.merge!(k => {})
            else
              result.merge!(k => get_include_for_find(v[:include]))
            end
          end
          result
        elsif includes.is_a?(Array)
          result = {}
          includes.each {|i| result.merge!(i => {}) }
          result
        else
          includes
        end
      end
    end

    # === Overview
    # 
    # This module contains methods that will be made available as instance
    # methods to any ActiveRecord model that calls <tt>acts_as_reportable</tt>.
    #
    module InstanceMethods

      # Grabs all of the object's attributes and the attributes of the
      # associated objects and returns them as an array of record hashes.
      # 
      # Associated object attributes are stored in the record with
      # "association.attribute" keys.
      # 
      # Passing :only as an option will only get those attributes.
      # Passing :except as an option will exclude those attributes.
      # Must pass :include as an option to access associations.  Options
      # may be passed to the included associations by providing the :include
      # option as a hash.
      # Passing :methods as an option will include any methods on the object.
      #
      # Example:
      # 
      #   class Book < ActiveRecord::Base
      #     belongs_to :author
      #     acts_as_reportable
      #   end
      # 
      #   abook.reportable_data(:only => ['title'], :include => [:author])
      #
      # Returns:
      #
      #   [{'title' => 'book title',
      #     'author.id' => 'author id',
      #     'author.name' => 'author name' }]
      #  
      # NOTE: title will only be returned if the value exists in the table.
      # If the books table does not have a title column, it will not be
      # returned.
      #
      # Example:
      #
      #   abook.reportable_data(:only => ['title'],
      #     :include => { :author => { :only => ['name'] } })
      #
      # Returns:
      #
      #   [{'title' => 'book title',
      #     'author.name' => 'author name' }]
      #
      def reportable_data(options = {})
        options = options.merge(self.class.aar_options) unless
          has_report_options?(options)

        # Grab and parse attributes for the current object
        # Includes :only, :except, and :methods processing
        data_records = [get_attributes_with_options(options)]

        columns = []

        # Reorder columns to match options[:only] order
        if options[:only]
          if options[:qualify_attribute_names]
            columns = [*options[:only]].map {|c| "#{options[:qualify_attribute_names]}.#{c}" }
          else
            columns = [*options[:only]].map {|c| c.to_s }
          end
        end

        # Include any columns not specified in :only but also in hash
        columns |= data_records.first.keys

        # Order columns alphabetically if :only option is unspecified
        unless options[:only]
          columns.sort!
        end

        if options[:include]
          data_records, new_columns = add_includes(data_records, options[:include])
          columns += new_columns unless new_columns.nil?
        end

        [data_records, columns]
      end

      private

      # Add data for all included associations
      #
      def add_includes(data_records, includes)
        include_has_options = includes.is_a?(Hash)
        associations = include_has_options ? includes.keys : [*includes]
        new_records = []
        new_columns = []

        associations.each do |association|
          if include_has_options
            assoc_options = includes[association].merge({
              :qualify_attribute_names => association
            })
          else
            assoc_options = {:qualify_attribute_names => association}
          end

          assoc_objects = [*send(association)]

          if assoc_objects.empty?
            # Nothing to do for this loop
            new_records = data_records
          else
            # Merge the associated objects own reportable data into the 2D records array
            assoc_objects.each do |assoc_object|
              if assoc_object.nil?
                data_records.each do |record|
                  new_records << record
                end
              else
                assoc_records, assoc_cols = assoc_object.reportable_data(assoc_options)
                new_columns |= assoc_cols
                data_records.each do |record|
                  assoc_records.each do |assoc_record|
                    new_records << record.merge(assoc_record)
                  end
                end
              end
            end
          end
          data_records = new_records
          new_records = []
        end
        [data_records, new_columns]
      end

      # Check if the options hash has any report options
      # (:only, :except, :methods, or :include).
      #
      def has_report_options?(options)
        options[:only] || options[:except] || options[:methods] ||
          options[:include]
      end

      # Get the object's attributes using the supplied options.
      # 
      # Use the :only or :except options to limit the attributes returned.
      #
      # Use the :qualify_attribute_names option to append the association
      # name to the attribute name as association.attribute
      #
      def get_attributes_with_options(options = {})
        attrs = attributes
        attrs.delete_if {|key, value| [*options[:except]].collect{|o| o.to_s}.include?( key.to_s) } if options[:except]
        attrs.delete_if {|key, value| ![*options[:only]].collect{|o| o.to_s}.include?( key.to_s) } if options[:only]
        if options[:methods]
          [*options[:methods]].each do |m|
            attrs[m.to_s] = send(m)
          end
        end
        if options[:qualify_attribute_names]
          attrs = attrs.inject({}) do |h,(k,v)|
            h["#{options[:qualify_attribute_names]}.#{k}"] = v
            h
          end
        end
        attrs
      end

    end
  end
end

ActiveRecord::Base.send :include, Ruport::Reportable
