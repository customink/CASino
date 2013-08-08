module CASino
  Error = Class.new(StandardError)
  ServiceNotAllowedError = Class.new(Error)
  AuthenticatorError = Class.new(Error)
end