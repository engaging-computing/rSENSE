# Helper method for seperating hashes.
# Removes the keys from hs that are in ls and returns them in a new hash
class Hash
  def extract_keys! (ls)
    res = self.select do |k, v|
      ls.include?(k)
    end

    self.keep_if do |k, v|
      not ls.include?(k)
    end
    res
  end
end