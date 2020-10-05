class String
  def to_underscore
    self.to_s.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_").downcase
  end

  def to_plural
    str = self.to_s
    pattern = /.*s$|x$|z$|sh$|ch$/
    pattern.match?(str) ? "#{str}es" : "#{str}s"
  end
end

