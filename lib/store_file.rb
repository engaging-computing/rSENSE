
require 'securerandom'

def store_make_key
  SecureRandom.hex
end

def store_uupath(store_key)
  d0 = store_key.slice(0, 2)
  "/media/#{d0}/#{store_key}"
end
  
def store_uudir(store_key)
  File.join(Rails.root, 'public', store_uupath(store_key))
end

def store_make_uudir!(store_key)
  FileUtils.mkdir_p(store_uudir(store_key), mode: 0755)
end
