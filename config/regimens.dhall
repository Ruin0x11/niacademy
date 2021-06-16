let JSON/Nesting = https://prelude.dhall-lang.org/v15.0.0/JSON/Nesting

let List/map = https://prelude.dhall-lang.org/v15.0.0/List/map

let SourceType = < File | Categories | Freeform | Custom >

let Categories
    : Type
    = { categories : List Text, imageCount : Natural, files : List Text }

let SourceData =
      < File : List Text | Categories : Categories | Freeform : Text | Custom >

let ProjectType = < Tutorial | Free >

let Source
    : Type
    = { type : SourceType, data : SourceData }

let Activity
    : Type
    = { id : Text
      , humanName : Text
      , description : Optional Text
      , source : Source
      , projectType : ProjectType
      }

let ActivitySegment
    : Type
    = { activityId : Text, durationMinutes : Natural, unboundedDuration : Bool }

let Regimen
    : Type
    = { id : Text
      , humanName : Text
      , defaultCategories : List Text
      , activities : List ActivitySegment
      }

let PresetRegimen
    : Type
    = { regimenId : Text, categories : Optional (List Text) }

let Preset
    : Type
    = { id : Text, humanName : Text, regimens : List PresetRegimen }

let generateActivityList =
      \(activityId : Text) ->
      \(durations : List Natural) ->
        List/map
          Natural
          ActivitySegment
          ( \(durationMinutes : Natural) ->
              { activityId, durationMinutes, unboundedDuration = False }
          )
          durations

let activities
    : List Activity
    = [   { id = "image-custom"
          , humanName = "Reference Image"
          , description = None Text
          , source = { type = SourceType.Custom, data = SourceData.Custom }
          , projectType = ProjectType.Tutorial
          }
        : Activity
      ,   { id = "dunn"
          , humanName = "Dunn"
          , description = Some "Workbook."
          , source =
            { type = SourceType.Freeform, data = SourceData.Freeform "Dunn" }
          , projectType = ProjectType.Tutorial
          }
        : Activity
      ,   { id = "fundamentals_2_dissections"
          , humanName = "Dissections"
          , description = Some "Dissections exercise"
          , source =
            { type = SourceType.Categories
            , data =
                SourceData.Categories
                  { categories = [ "textures/pinterest" ]
                  , imageCount = 10
                  , files = [ "female_clothed/test/rina1.png" ] : List Text
                  }
            }
          , projectType = ProjectType.Tutorial
          }
        : Activity
      ,   { id = "free_draw"
          , humanName = "Free Draw"
          , description = None Text
          , source =
            { type = SourceType.Freeform
            , data = SourceData.Freeform "Free draw."
            }
          , projectType = ProjectType.Free
          }
        : Activity
      ]

let regimens
    : List Regimen
    = [ { id = "figure_30"
        , humanName = "Figure drawing (30 minutes, 1-1-1-1-1-1-2-2-5-5-10)"
        , defaultCategories = [] : List Text
        , activities =
            generateActivityList
              "image-custom"
              [ 1, 1, 1, 1, 1, 1, 2, 2, 5, 5, 10 ]
        }
      , { id = "textures"
        , humanName = "Textures"
        , defaultCategories = [] : List Text
        , activities =
          [ { activityId = "fundamentals_2_dissections"
            , durationMinutes = 1
            , unboundedDuration = True
            }
          ]
        }
      ]

let presets
    : List Preset
    = [ { id = "fig_dab2_3"
        , humanName = "Figures/DaB 2.3 Dissections"
        , regimens =
          [ { regimenId = "figure_30", categories = Some [ "female_clothed" ] }
          , { regimenId = "textures", categories = None (List Text) }
          ]
        }
      , { id = "test"
        , humanName = "Test"
        , regimens =
          [ { regimenId = "textures", categories = None (List Text) } ]
        }
      ]

let PresetOrder
    : Type
    = { tutorial : List Text, free : List Text }

let presetOrderTutorial
    : List Text
    = [ "fig_dab2_3", "test" ]

let presetOrderFree
    : List Text
    = [ "fig_dab2_3", "test" ]

let presetOrder
    : PresetOrder
    = { tutorial = presetOrderTutorial, free = presetOrderFree }

let Config
    : Type
    = { activities : List Activity
      , regimens : List Regimen
      , presets : List Preset
      , presetOrder : PresetOrder
      }

let config
    : Config
    = { activities, regimens, presets, presetOrder }

in  config
