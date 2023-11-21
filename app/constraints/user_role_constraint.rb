# frozen_string_literal: true

class UserRoleConstraint
  def initialize(lambda_function)
    @lambda_function = lambda_function
  end

  def matches?(request)
    # Call the lambda function and pass the request as an argument
    @lambda_function.call(request)
  end
end
