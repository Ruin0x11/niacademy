let JSON/Nesting = https://prelude.dhall-lang.org/v15.0.0/JSON/Nesting

let List/map = https://prelude.dhall-lang.org/v15.0.0/List/map

let SourceType = < File | Categories | Freeform | Custom >

let SourceData =
      < File : Text | Categories : List Text | Freeform : Text | Custom >

let Source
    : Type
    = { type : SourceType, data : SourceData }

let Activity
    : Type
    = { id : Text
      , humanName : Text
      , description : Optional Text
      , source : Source
      }

let ActivitySegment
    : Type
    = { activityId : Text, durationMinutes : Natural }

let Regimen
    : Type
    = { id : Text
      , humanName : Text
      , defaultCategories : List Text
      , activities : List ActivitySegment
      }

let activities
    : List Activity
    = [   { id = "image-custom"
          , humanName = "Reference Image"
          , description = None Text
          , source = { type = SourceType.Custom, data = SourceData.Custom }
          }
        : Activity
      ,   { id = "dunn"
          , humanName = "Dunn"
          , description = Some "Workbook."
          , source =
            { type = SourceType.Freeform, data = SourceData.Freeform "Dunn" }
          }
        : Activity
      ]

let generateActivityList =
      \(activityId : Text) ->
      \(durations : List Natural) ->
        List/map
          Natural
          ActivitySegment
          (\(durationMinutes : Natural) -> { activityId, durationMinutes })
          durations

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
      ]

let Config
    : Type
    = { activities : List Activity, regimens : List Regimen }

let config
    : Config
    = { activities, regimens }

in  config
