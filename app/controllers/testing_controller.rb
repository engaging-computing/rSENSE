class TestingController < ApplicationController
  # GET /testing    
  def index
    json_issues = JSON.parse HTTParty.get('https://api.github.com/repos/iSENSEDev/rSENSE/issues?labels=In+Testing', :headers => {"User-Agent" => "rSENSE"}).response.body
    @issues = Array.new()
    json_issues.each do |json_issue|
      @issues.push(Hash["number",json_issue["number"],"html_url",json_issue["html_url"],"title",json_issue["title"]])
    end
    @issues.inspect() 

    #JSON.parse HTTParty.post('https://api.github.com/repos/AlanRosenthal/rSENSE/issues/1/comments', :headers => {"User-Agent" => "rSENSE","Authorization" => "token 6b04ab36543bbdf5a656eca1d5cf165cc1912752"},:body => { "body" => "test123" }.to_json).response.body
  end
  # POST /testing/review
  def review
    @issues = params[:issues]
  end

  # POST /testing/publish
  def publish
    @params = params
  end
end
