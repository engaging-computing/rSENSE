ActionView::Base.sanitized_allowed_tags.replace %w(br p strong i em a del pre img ul ol li h1 h2 h3 h4 h5 table thead tbody tr td hr video)
ActionView::Base.sanitized_allowed_attributes.replace %w(style href src)
