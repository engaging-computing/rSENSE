module ApplicationHelper

  def include_page_spesific_js
    if FileTest.exists? "app/assets/javascripts/"+params[:controller]+"/"+params[:action]+".js.coffee.erb"
      return '<script src="/assets/'+params[:controller]+'/'+params[:action]+'.js.coffee.erb" type="text/javascript"></script>'
    end
  end

end
