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
                  Please describe your project in detail, so that other users can find it. If
                  applicable, please specify what academic subject(s) the project relates to
                  and which grade level(s) it is appropriate for. (E.g., In this project,
                  students will collect water quality data from the Charles River. This is an
                  earth science and biology project suitable for students in middle school
                  and high school.)
                </p>

                <h3>PROCEDURE</h3>
                <p>
                  If the project involves users collecting or visualizing data, please
                  provide step-by-step instructions for these activities. (E.g., 1. Collect a
                  sample of water. 2. Perform temperature, pH, and dissolved oxygen
                  measurements on the sample. 3. Upload the data to iSENSE. 4. Make a scatter
                  chart to look for relationships between different values.)
                </p>

                <h3>SOURCE</h3>
                <p>
                  If the project contains an existing data set, please specify the source of
                  the data, including a web link or bibliographical reference. (E.g., <a href="http://www.crwa.org/water_quality.html">http://www.crwa.org/water_quality.html</a>)
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
          title: "Dataset Template"
          description: "Basic template for describing a dataset."
          html: """  
                <h3>COLLECTION METHOD</h3>
                <p>
                  Please describe how, when, and where these data were collected. (E.g. This
                  data set includes temperature, pH, dissolved oxygen, salinity, and
                  turbidity measurements from water samples collected near the Museum of
                  Science in the Charles River's lower basin.)
                </p>

                <h3>DATA SOURCE</h3>
                <p>
                  For existing data sets, please specify where the data were obtained. (E.g.
                  These data were provided online by the Charles River Watershed Association. <a href="http://www.crwa.org/water_quality.html">http://www.crwa.org/water_quality.html</a>)
                </p>
                """
        }]
    
  if namespace.controller is "visualizations" and namespace.action is "show"
    #add saved vis templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "Visualization Template"
          description: "Basic template for describing a visualization."
          html: """
                <h3>DATA</h3>
                <p>
                  Please describe which data sets have been included in the saved
                  visualization. (E.g., This scatter plot shows water temperature
                  measurements and dissolved oxygen levels from two sampling stations in the
                  Charles River.)
                </p>

                <h3>PATTERNS</h3>
                <p>
                  Please describe any patterns or trends that you see in the data. (E.g.,
                  There is a linear relationship between the values on the X axis and the
                  values on the Y axis.)
                </p>

                <h3>OBSERVATIONS</h3>
                <p>
                  Please report any observations or conclusions you have drawn from the
                  visualization here. (E.g., In general, higher water temperatures are
                  correlated with lower dissolved oxygen levels.)
                </p>
                """
        }]
    
    
  if namespace.controller is "users"
    #add bio templates here
    CKEDITOR.addTemplates "all", 
      templates:
        [{
          title: "User Template"
          description: "Basic template for user biography."
          html: """  
                <h3>INSTITUTIONAL AFFILIATION</h3>
                <p>
                  Please describe your institutional affiliation(s). (E.g., I teach
                  seventh-grade earth science at the Kathryn P. Stoklosa Middle School in
                  Lowell, Massachusetts.)
                </p>

                <h3>RELEVANT INTERESTS</h3>
                <p>
                  Please describe your specific interests in using iSENSE. (E.g., I am
                  interested in incorporating iSENSE in my classroom science teaching.)
                </p>
                """
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
    