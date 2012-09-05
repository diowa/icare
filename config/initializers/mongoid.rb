module Mongoid
  module MassAssignmentSecurity
    extend ActiveSupport::Concern

    included do
      attr_accessible nil
    end
  end

  module Document
    include MassAssignmentSecurity
  end
end

# This monkey patches Mongoid's multi-parameter attribute handling in the same
# way that the enable_multiparameter_extension! option of validates_timeliness
# does for ActiveRecord -- to enable it to gracefully return errors to the user
# when they enter a date like February 30th.
#
# This is not thoroughly tested yet, but appears to work for Date fields at
# least. Last tested with (I think) Mongoid 2.0.0.beta20
=begin
module Mongoid #:nodoc:
  module MultiParameterAttributes #:nodoc:

  #TODO understand what TO DO (multiparameters validation)

  protected
    def invalid_multiparameter_date_or_time_as_string(values)
      value =  [values[0], *values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
      value += ' ' + values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless values[3..5].empty?
      ""
    end

    def instantiate_time_object(values)
      if Date.valid_civil?(*values[0..2])
        Date.send(:convert_to_time, values)
      else
        invalid_multiparameter_date_or_time_as_string(values)
      end
    end

    def instantiate_date_object(values)
      Date.new(*values)
    rescue
      invalid_multiparameter_date_or_time_as_string(values)
    end

    def instantiate_object(field, values_with_empty_parameters)
      return nil if values_with_empty_parameters.all? { |v| v.nil? }
      values = values_with_empty_parameters.collect { |v| v.nil? ? 1 : v }
      klass = field.type
      if klass == DateTime || klass == Time
        instantiate_time_object(values)
      elsif klass == Date
        instantiate_date_object(values)
      elsif klass
        klass.new(*values)
      else
        values
      end
    end
  end
end
=end
