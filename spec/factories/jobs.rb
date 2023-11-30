FactoryBot.define do
  factory :job1, class: ActivejobWeb::Job do
    title { 'Job title' }
    description {'description for job'}
   end
end
