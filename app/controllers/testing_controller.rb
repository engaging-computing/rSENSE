class TestingController < ApplicationController
  # GET /testing
  def index
    github_response = HTTParty.get('https://api.github.com/repos/engaging-computing/rSENSE/issues?labels=In+Testing', headers: { 'User-Agent' => 'rSENSE' }).response
    json_issues = JSON.parse github_response.body
    user_agent = request.env['HTTP_USER_AGENT']
    @browser = Browser.new(ua: user_agent, accept_language: 'en-us')
    @issues = []
    if github_response.code == '200'
      json_issues.each do |json_issue|
        @issues.push(Hash['number', json_issue['number'], 'html_url', json_issue['html_url'], 'title', json_issue['title']])
      end
    end
  end

  # POST /testing/review
  def review
    @issues = params[:issues]
    @userinfo = params[:userinfo]
  end

  # POST /testing/publish
  def publish
    @issues = params[:issues]
    @github_auth_token = params[:userinfo][:auth_token]
  end
end
