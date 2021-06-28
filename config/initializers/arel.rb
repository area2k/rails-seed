module ArelNodeFunctions
  def concat_ws(*args)
    Arel::Nodes::ConcatWs.new(self, *args)
  end
end

Arel::Attributes::Attribute.include ArelNodeFunctions
Arel::Nodes::Node.include ArelNodeFunctions

Arel::SPACE = Arel::Nodes::SqlLiteral.new('" "')
