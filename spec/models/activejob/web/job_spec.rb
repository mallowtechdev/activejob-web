# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::Job, type: :model do
  let(:job) { FactoryBot.create(:job) }

  it 'is valid with valid attributes' do
    expect(job).to be_valid
  end

  it 'is not valid without a title' do
    job.title = nil
    expect(job).to_not be_valid
  end

  it 'is not valid without a job_name' do
    job.job_name = nil
    expect(job).to_not be_valid
  end
end
