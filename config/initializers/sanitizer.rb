HTML::WhiteListSanitizer.allowed_protocols << 'data'
ActionView::Base.sanitized_allowed_tags.replace %w(iframe img br p strong i em a del pre ul ol li h1 h2 h3 h4 h5 table thead tbody tr td hr video div span)
ActionView::Base.sanitized_allowed_attributes.replace %w(style href src)
