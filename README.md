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
```
where, `job_approvers_class` and `job_executors_class` were defined as `mattr_accessors` in Activejob Web gem

## Configuration for Authentication
The ActivejobWeb Gem integrates with the authentication system used in your Rails application. To set up authentication, create a helper file named `user_helper.rb` with the following methods:

```ruby
# app/helpers/user_helper.rb

module UserHelper
  def my_app_current_user
    # Specify the current user here
    User.find(current_user.id)
  end

  def my_app_login_path
    # specify the path to redirect while user not signed in
    login_path
  end
end
```
In the `my_app_current_user` method, specify the logic to fetch the current user for authentication. Replace the placeholder `User.find(current_user.id)` with the actual code that retrieves the current user.

For the `my_app_login_path` method, specify the path to redirect the user to when they are not signed in. Replace `login_path` with the actual path you want to use for user login.

## Enabling Routes for specific users to edit the Jobs
By enabling this route, The specified super admin users will only have permission to edit the jobs. The implementation involves utilizing `route constraints` and a custom `lambda function` to restrict access based on a `super admin scope`.
Assuming that your model to configure is 'User'.
### 1. Define a scope named `super_admin_users` in the `User` model 
Specify the condition in the scope that it should return the users with the permission for the edit page of jobs. The example code was shown below the custom lambda
### 2. Define a Custom Lambda Method

In your `User` model or the model you defined for approvers/executors, define a method named `custom_lambda` that represents the condition for user access. This lambda function will be used as a route constraint.

```ruby
# app/models/user.rb

class User < ApplicationRecord
  # Your existing user model code

  # Define a scope for super admins here
  scope :super_admin_user, -> { User.all.limit(10) }

  # Your other scopes and methods...

  # Define a custom lambda function for route constraint
  def self.custom_lambda
    lambda do |_request|
      my_current_user = User.find(current_user.id)
      super_admin_user.include?(my_current_user)
      # Your custom logic to determine user access goes here
    end
  end
end
```
If the condition specified in the `custom_lambda` returns `true` the current user can able to edit the jobs

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
