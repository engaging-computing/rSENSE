module HomeHelper
	def ios_device?		
	  if (request.user_agent =~ /ip(hone|od|ad)/i) != nil
	    true
	  else
	    false
	  end		
	end
end
