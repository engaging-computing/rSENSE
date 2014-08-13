class TestingController < ApplicationController
  # GET /testing    
  def index
    json_issues = JSON.parse HTTParty.get('https://api.github.com/repos/iSENSEDev/rSENSE/issues?labels=In+Testing', :headers => {"User-Agent" => "rSENSE"}).response.body
    @issues = Array.new()
    json_issues.each do |json_issue|
      @issues.push(Hash["number",json_issue["number"],"html_url",json_issue["html_url"],"title",json_issue["title"]])
    end
    @issues.inspect() 
  end
  
  # POST /testing/review
  def review
    @issues = params[:issues]
    @userinfo = params[:userinfo]
  end

  # POST /testing/publish
  def publish
    issues = params[:issues]
    github_auth_token = params[:userinfo][:auth_token]
    
    issues.each do |issue|
        api_url = "https://api.github.com/repos/isenseDev/rSENSE/issues/#{issue[0]}/comments"
        response = HTTParty.post(api_url,:headers => {"User-Agent" => "rSENSE","Authorization" => "token #{github_auth_token}"},:body => { "body" => issue[1][:message] }.to_json).response
        puts response.code
        puts response.body
        if response.code == 201
            puts "Issue #{issue[0]} Successfully Posted to GitHub"
        end
    end 
  end
end
