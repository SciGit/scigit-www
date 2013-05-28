class String
  def or(default)
    self.empty? ? default : self
  end
end

class NilClass
  def or(default)
    default
  end
end
