module CASino
  class AbstractAuthenticator
    def validate(username, password)
      raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
    end
  end
end