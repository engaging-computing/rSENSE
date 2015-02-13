class GithubInterface
  class << self; attr_accessor :test end

  # Authenticate against github with generated codes.
  def self.authenticate(code)
    new_params = {}
    # IMPORTANT #
    # These variables need to be set on the machine that is running the server
    new_params[:client_id] = ENV['GITHUB_ID']
    new_params[:client_secret] = ENV['GITHUB_SECRET']
    new_params[:code] = code

    url = URI.parse('https://github.com/login/oauth/access_token')

    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data(new_params)
    req['accept'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    response = http.request(req)

    JSON.parse(response.body)
  end

  # Sends a formatted issue to iSENSE
  def self.send_issue(params)
    if params[:description] == ''
      redirect_to :back
      flash[:error] = 'Please fill out all required fields.'
    else
      b =  "**General description:** #{params[:description]}\n\n"\
           "**live/dev/localhost:** live\n"\
           "**iSENSE Version:** #{params[:isense_version]}\n"\
           "**Logged in (Y or N):** #{params[:logged_in]}\n"\
           "**Admin (Y or N):** #{params[:is_admin]}\n\n"\
           "**OS:** #{params[:os]}\n"\
           "**Browser/Version:** #{params[:browser]}\n\n"\
           "**Steps to Reproduce:** #{params[:instructions]}\n\n"\
           "#{params[:user_id]}"

      new_params = {}
      new_params['title'] = 'User Submitted Issue'
      new_params['body'] = b

      base_url = 'https://api.github.com/repos/isenseDev/rSENSE/issues'
      token = '?access_token=' + params[:access_token]
      url = URI.parse(base_url + token)

      req = Net::HTTP::Post.new(url.request_uri)
      req.body = new_params.to_json
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      response = http.request(req)
      response
    end
  end
end