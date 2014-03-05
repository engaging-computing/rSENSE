# Place all the behaviors and hooks related to the users index page here.
$ ->
  if namespace.controller is "users" and namespace.action is "index"

    ($ ".users_sort_select").change ->
      ($ "#users_search").submit()

    helpers.isotope_layout('#users')

    ($ window).resize () ->
      helpers.isotope_layout("#users")
