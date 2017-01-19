# Generate a gravatar url of the given size for the given user
class Gravatar
  def url(user, size = 150)
    hash = Digest::MD5.hexdigest(user.email.downcase)
    "https://gravatar.com/avatar/#{hash}.png?s=#{size}"
  end
end
