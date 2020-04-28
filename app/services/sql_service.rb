# frozen_string_literal: true

module SQLService
  module_function

  def columns(model, except: %w[id])
    (model.column_names - except)
  end

  def execute(sql)
    ApplicationRecord.connection.execute(sql.tr("\n", ' '))
  end

  def insert(model, values, except: %w[id], columns: columns(model, except: except))
    SQLService.execute <<~SQL
      INSERT INTO #{model.table_name} (#{columns.join(', ')})
      VALUES #{values.join(', ')}
    SQL
  end

  def quote(sql_string_value)
    ApplicationRecord.connection.quote(sql_string_value)
  end

  def to_values(*args)
    array = args.flatten
    bindings = generate_bindings(array.size)
    result = ApplicationRecord.sanitize_sql_array([bindings, *array])

    "(#{result})"
  end

  def transaction(*args)
    ApplicationRecord.transaction(*args) { yield }
  end

  ## private ##

  def generate_bindings(count)
    "?#{', ?' * (count - 1)}"
  end
  private_class_method :generate_bindings
end
