module HomeHelper
  def ios_device?
    if request.user_agent =~ /ip(hone|od|ad)/i
      true
    else
      false
    end
  end

  def current_url(p)
    url_for params: params.merge(p)
  end
end