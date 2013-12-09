###
This file is used to store ckeditor templates.

Templates should be added on a per namespace/method basis as the first template
present in 'all' will always be used as a default.
###

$ ->
  if namespace.controller is "projects"
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Project Template"
          description: "Basic template for describing a project."
          html: """
                <h3>OVERVIEW</h3>
                <p>
                  Please describe your project in detail, so that other users can find it. If applicable, please specify what academic subject(s) the project relates to and which grade level(s) it is appropriate for.
                </p>

                <h3>PROCEDURE</h3>
                <p>
                  If the project involves students collecting or visualizing data, please provide step-by-step instructions for these activities.
                </p>

                <h3>SOURCE</h3>
                <p>
                  If the project contains a curated data set, please specify the source of the data, including a web link or bibliographic reference.
                </p>
                """
#         },{
#           title: "Template 2"
#           description: "test"
#           html: "hi"
        }]
        
  if namespace.controller is "visualizations" and namespace.action is "displayVis"
    #add dataset templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Blank Template"
          description: "This is a blank template."
          html: """  """
        }]
    
  if namespace.controller is "visualizations" and namespace.action is "show"
    #add saved vis templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Blank Template"
          description: "This is a blank template."
          html: """  """
        }]
    
    
  if namespace.controller is "users"
    #add bio templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Blank Template"
          description: "This is a blank template."
          html: """  """
        }]
    
    
  if namespace.controller is "tutorials"
    #add tutorial templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Blank Template"
          description: "This is a blank template."
          html: """  """
        }]
    
    
  if namespace.controller is "news"
    #add news templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Blank Template"
          description: "This is a blank template."
          html: """  """
        }]
    