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
# class UserRoleConstraint
#   def initialize(role)
#     @role = role
#   end
#
#   def matches?(request)
#     user_id = request.session[:user_id] # Assuming the user's ID is stored in the session
#     user = User.find_by(id: user_id)
#     user && user.role == @role
#   end
# end
