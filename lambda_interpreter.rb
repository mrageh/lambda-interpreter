App = Struct.new(:left, :right) do
  def to_s
    "#{left} #{right}"
  end

  def inspect
    to_s
  end

  def reducible?
    true
  end
end

Abs = Struct.new(:param, :body) do
  def to_s
    "λ#{param}.#{body}"
  end

  def inspect
    to_s
  end

  def reducible?
    body.reducible? || false
  end
end

Var = Struct.new(:name) do
  def to_s
    "#{name}"
  end

  def inspect
    to_s
  end

  def reducible?
    false
  end
end

def App(left, right)
  App.new(left, right)
end

def Abs(param, body)
  Abs.new(param, body)
end

def Var(var)
  Var.new(var)
end

def evaluate(expression)
  case expression
  when App
    if expression.left.is_a?(Abs) && expression.right.is_a?(Abs)
      name_of_thing_to_replace = expression.left.param
      thing_to_replace_inside = expression.left.body
      thing_to_replace_with = expression.right
      replace(name_of_thing_to_replace, thing_to_replace_inside, thing_to_replace_with)
    elsif expression.left.is_a?(Abs) && !expression.right.is_a?(Abs)
      if expression.right.is_a?(App)
        name_of_thing_to_replace = expression.left.param
        thing_to_replace_inside = expression.left.body
        thing_to_replace_with = evaluate(expression.right)
        replace(name_of_thing_to_replace, thing_to_replace_inside, thing_to_replace_with)
      elsif expression.right.is_a?(Var)
        name_of_thing_to_replace = expression.left.param
        thing_to_replace_inside = expression.left.body
        thing_to_replace_with = expression.right
        replace(name_of_thing_to_replace, thing_to_replace_inside, thing_to_replace_with)
      end
    elsif expression.left.is_a?(App)
      left_expression = evaluate(expression.left)
      if expression.right.is_a?(App)
        name_of_thing_to_replace = left_expression.param
        thing_to_replace_inside = left_expression.body
        thing_to_replace_with = evaluate(expression.right)
        replace(name_of_thing_to_replace, thing_to_replace_inside, thing_to_replace_with)
      elsif expression.right.is_a?(Abs)
        name_of_thing_to_replace = left_expression.param
        thing_to_replace_inside = left_expression.body
        thing_to_replace_with = expression.right
        replace(name_of_thing_to_replace, thing_to_replace_inside, thing_to_replace_with)
      end
    end
  else
    raise "Can't evaluate #{expression}"
  end
end

def replace(name, term, replacement)
  case term
  when Var
    if name == term.name
      replacement
    else
      term
    end
  when Abs
    if name == term.param
      term
    else
      body = replace(name, term.body, replacement)
      Abs(term.param, body)
    end
  when App
    left = replace(name, term.left, replacement)
    right = replace(name, term.right, replacement)
    App(left, right)
  end
end
