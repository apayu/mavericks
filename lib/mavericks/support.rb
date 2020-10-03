module Mavericks
  def self.to_underscore(string)
    string.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_").downcase
  end

  def self.to_plural(string)
    pattern = /.*s$|x$|z$|sh$|ch$/
    pattern.match?(string) ? "#{string}es" : "#{string}s"
  end
end
