# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivejobWeb::Jobs', type: :request do
  describe 'GET /index' do
    context 'returns a successful response' do
      it 'Valid index' do
        get activejob_web_jobs_path
        expect(response).to render_template('index')
        expect(response).to have_http_status 200
      end
    end
  end
  describe 'GET #show' do
    context 'returns a successful response' do
      it 'Valid show' do
        data = ActivejobWeb::Job.create(title: 'Test1', description: 'Test description')
        get activejob_web_job_path(data.id)
        expect(response).to render_template('show')
        expect(response).to have_http_status 200
      end
    end
  end
end
