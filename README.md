# Activejob::Web
ActiveJob::Web is a Rails engine that provides a web-based dashboard for managing and monitoring background job processing  in a Ruby on Rails application.


## Usage
rails plugin new activejob-web --full


## Installation
Add this line to your application's Gemfile:

```ruby
gem "activejob-web"
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install activejob-web
```


## Configuring Activejob Web approvers and executors

By default, Activejob Web uses the `User` class as the model for job approvers and executors. If you need to customize these classes, you can do so in the initializer file located at `config/initializers/activejob_web.rb`.

For example, if your model to configure is 'Author', you can set the job approvers and executors classes as follows:

```ruby
# config/initializers/activejob_web.rb

Activejob::Web.job_approvers_class = 'Author'
Activejob::Web.job_executors_class = 'Author'
Activejob::Web.job_admins_class = 'Author'
```
where, `job_approvers_class`, `job_executors_class` and `job_admins_class` were defined as `mattr_accessors` in Activejob Web gem.

## Configuration for Authentication
The ActivejobWeb Gem integrates with the authentication system used in your Rails application. To set up authentication, specify the `current_user` and `login_path` in the `apps/helpers/authentication_helper.rb` file as shown below,

```ruby
# app/helpers/authentication_helper.rb

module AuthenticationHelper
  def activejob_web_current_user
    # Specify the current user here
    current_user
  end

  def activejob_web_login_path
    # Specify the path to redirect when user not authenticated
    root_path
  end
end
```
In the `activejob_web_current_user` method, specify the logic to fetch the current user for authentication.

In the `activejob_web_login_path` method, On default it will have root_path but you can specify the path that the user have to redirected, if not signed in.

Make sure that your application controller includes the helper file named `AuthenticationHelper` and **helper_method** `activejob_web_current_user` as shown below,
if not included please include the helper file and helper_method for the authentication related configurations. The redirection of users were specified in the application controller with the method name `activejob_web_authenticate_user` as shown below

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include AuthenticationHelper
  helper_method :activejob_web_current_user
  before_action :activejob_web_authenticate_user
  protect_from_forgery with: :exception

  protected

  def activejob_web_authenticate_user
    return if session[:authentication_checked]

    return unless activejob_web_current_user.nil?

    session[:authentication_checked] = true
    redirect_to activejob_web_login_path, alert: 'Please log in'
  end
end
```

## Enabling Routes for specific users to edit the Jobs
By enabling this route, The specified super admin users will only have permission to edit the jobs. The implementation involves utilizing `route constraints` and a custom `lambda function` to restrict access based on a `super admin scope`.
Assuming that your model to configure is 'User'.
### 1. Define a scope named `active_job_admins` in the `User` model
Specify the condition in the scope that it should return the users with the permission for the edit page of jobs. The example code was shown below the custom lambda.
### 2. Define a Custom Lambda Method

In your `User` model or the model you defined for approvers/executors, define a method named `allow_admin_access?` that represents the condition for user access. This lambda function will be used as a route constraint.

```ruby
# app/models/user.rb

class User < ApplicationRecord
  # Your existing user model code

  # Define a scope for super admins here
  scope :active_job_admins, -> { User.all.limit(10) }

  # Your other scopes and methods...

  # Define a custom lambda inside a method for route constraint
  def self.allow_admin_access?
    lambda do |_request|
      active_job_admins.include?(current_user)
      # Your custom logic to determine user access goes here
    end
  end
end
```
If the condition specified in the `allow_admin_access?` returns `true` the current user can able to edit the jobs.

### 3. Route customization
In Activejob Web, you have the flexibility to customize routes based on specific user requirements. By default, every user is allowed to edit jobs, but you can customize the routes to be accessible only by specific users.

For that, first you have to specify the scope and lambda for the `User` or the required model as mentioned in the previous points.Then, start by configuring the `enable_custom_routes` option in the initializer file `activejob_web.rb`. Set it to `true` as shown below:

```ruby
# config/initializers/activejob_web.rb

Rails.application.config.enable_custom_routes = true
```
Your routes for jobs edit will look like this
```ruby
# config/routes.rb

if Rails.application.config.enable_custom_routes == true
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit',
                                       constraints: UserRoleConstraint.new(Activejob::Web.job_approvers_class.constantize.allow_admin_access?),
                                       as: 'edit_activejob_web_job'
  else
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit'
  end
```
In this route, you have to customize the method name `allow_admin_access?` if you are using a different name for the method.

The edit jobs route uses a constraint file named `user_role_constraint.rb` for processing the lambda you define in the `allow_admin_access?` method as shown below,
```ruby
# app/constraints/user_role_constraint.rb

class UserRoleConstraint
  def initialize(lambda_function)
    @lambda_function = lambda_function
  end

  def matches?(request)
    # Call the lambda function and pass the request as an argument
    @lambda_function.call(request)
  end
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
