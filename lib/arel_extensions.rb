require 'arel'

require 'arel_extensions/railtie' if defined?(Rails::Railtie)

# UnaryOperation|Grouping|Extract < Unary < Arel::Nodes::Node
# Equality|Regexp|Matches < Binary < Arel::Nodes::Node
# Count|NamedFunction < Function < Arel::Nodes::Node

# pure Arel internals improvements
Arel::Nodes::Binary.class_eval do
  include Arel::AliasPredication
  include Arel::Expressions
end

Arel::Nodes::Casted.class_eval do
  include Arel::AliasPredication
end

Arel::Nodes::Unary.class_eval do
  include Arel::Math
  include Arel::AliasPredication
  include Arel::Expressions
end

Arel::Nodes::Grouping.class_eval do
  include Arel::Math
  include Arel::AliasPredication
  include Arel::OrderPredications
  include Arel::Expressions
end

Arel::Nodes::Function.class_eval do
  include Arel::Math
  include Arel::Expressions
end

if Arel::VERSION >= "7.1.0"
  Arel::Nodes::Case.class_eval do
    include Arel::Math
    include Arel::Expressions
  end
end

require 'arel_extensions/version'
require 'arel_extensions/attributes'
require 'arel_extensions/visitors'
require 'arel_extensions/nodes'
require 'arel_extensions/comparators'
require 'arel_extensions/date_duration'
require 'arel_extensions/null_functions'
require 'arel_extensions/boolean_functions'
require 'arel_extensions/math'
require 'arel_extensions/math_functions'
require 'arel_extensions/string_functions'
require 'arel_extensions/set_functions'
require 'arel_extensions/predications'

require 'arel_extensions/insert_manager'

require 'arel_extensions/common_sql_functions'

require 'arel_extensions/nodes/union'
require 'arel_extensions/nodes/union_all'
require 'arel_extensions/nodes/case'
require 'arel_extensions/nodes/soundex'
require 'arel_extensions/nodes/cast'
require 'arel_extensions/nodes/json'



module Arel
  def self.rand
    ArelExtensions::Nodes::Rand.new
  end

  def self.shorten s
    Base64.urlsafe_encode64(Digest::MD5.new.digest(s)).tr('=', '').tr('-', '_')
  end

  def self.json *expr
    if expr.length == 1
      ArelExtensions::Nodes::Json.new(expr.first)
    else
      ArelExtensions::Nodes::Json.new(expr)
    end
  end

  def self.when condition
    ArelExtensions::Nodes::Case.new.when(condition)
  end

  def self.duration s, expr
    ArelExtensions::Nodes::Duration.new(s.to_s+'i',expr)
  end
  
    # Wrap a known-safe SQL string for passing to query methods, e.g.
  #
  #   Post.order(Arel.sql("length(title)")).last
  #
  # Great caution should be taken to avoid SQL injection vulnerabilities.
  # This method should not be used with unsafe values such as request
  # parameters or model attributes.
  def self.sql(raw_sql)
    Arel::Nodes::SqlLiteral.new raw_sql
  end

  def self.star # :nodoc:
    sql "*"
  end

  def self.arel_node?(value) # :nodoc:
    value.is_a?(Arel::Node) || value.is_a?(Arel::Attribute) || value.is_a?(Arel::Nodes::SqlLiteral)
  end

  def self.fetch_attribute(value) # :nodoc:
    case value
    when Arel::Nodes::Between, Arel::Nodes::In, Arel::Nodes::NotIn, Arel::Nodes::Equality, Arel::Nodes::NotEqual, Arel::Nodes::LessThan, Arel::Nodes::LessThanOrEqual, Arel::Nodes::GreaterThan, Arel::Nodes::GreaterThanOrEqual
      yield value.left.is_a?(Arel::Attributes::Attribute) ? value.left : value.right
    end
  end

  ## Convenience Alias
  Node = Arel::Nodes::Node # :nodoc:


end

Arel::Attributes::Attribute.class_eval do
  include Arel::Math
  include ArelExtensions::Attributes
end

Arel::Nodes::Function.class_eval do
  include ArelExtensions::Math
  include ArelExtensions::Comparators
  include ArelExtensions::DateDuration
  include ArelExtensions::MathFunctions
  include ArelExtensions::StringFunctions
  include ArelExtensions::BooleanFunctions
  include ArelExtensions::NullFunctions
  include ArelExtensions::Predications
end

Arel::Nodes::Unary.class_eval do
  include ArelExtensions::Math
  include ArelExtensions::Attributes
  include ArelExtensions::MathFunctions
  include ArelExtensions::Comparators
  include ArelExtensions::Predications
end

Arel::Nodes::Binary.class_eval do
  include ArelExtensions::Math
  include ArelExtensions::Attributes
  include ArelExtensions::MathFunctions
  include ArelExtensions::Comparators
  include ArelExtensions::BooleanFunctions
  include ArelExtensions::Predications
end

Arel::Nodes::Equality.class_eval do
  include ArelExtensions::Comparators
  include ArelExtensions::DateDuration
  include ArelExtensions::MathFunctions
  include ArelExtensions::StringFunctions
end


Arel::InsertManager.class_eval do
  include ArelExtensions::InsertManager
end

Arel::SelectManager.class_eval do
  include ArelExtensions::SetFunctions
  include ArelExtensions::Nodes
end

Arel::Nodes::As.class_eval do
  include ArelExtensions::Nodes
end


