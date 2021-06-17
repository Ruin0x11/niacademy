let JSON/Nesting = https://prelude.dhall-lang.org/v15.0.0/JSON/Nesting

let List/map = https://prelude.dhall-lang.org/v15.0.0/List/map

-- Used with the categories screen: one or more images that will always appear
-- as a prompt/guideline, and a set of N randomly selected image.
let Categories
    : Type
    = { categories : List Text, imageCount : Natural, files : List Text }

-- Because Dhall doesn't have typed unions...
let SourceType = < File | Categories | Freeform | Custom >
let SourceData =
      < File : List Text | Categories : Categories | Freeform : Text | Custom >

-- The data needed to show an activity on the screen. Can be one or more
-- specific images, a set of categories to randomly choose images from, or just
-- some text.
let Source
    : Type
    = { type : SourceType, data : SourceData }

-- Indicates if the time spent on an activity counts towards fulfilling
-- tutorial-based learning or free drawing.
let ProjectType = < Tutorial | Free >

-- A single screen of content that appears in the overall sequence. For example,
-- it can display a picture of a pose to copy from, or a series of related
-- images to gather ideas from.
let Activity
    : Type
    = { id : Text
      , humanName : Text
      , description : Optional Text
      , source : Source
      , projectType : ProjectType
      }

-- An activity with a time associated with it, for use with a regimen. If
-- `unboundedDuration` is True, the skip button will appear after the specified
-- minimum duration has passed, and the user will choose when to proceed to the
-- next activity. Otherwise, the activity will be changed automatically.
let ActivitySegment
    : Type
    = { activityId : Text, durationMinutes : Natural, unboundedDuration : Bool }

-- A set of drawing activities that are timed and automatically progressed
-- through.
let Regimen
    : Type
    = { id : Text
      , humanName : Text
      , defaultCategories : List Text
      , activities : List ActivitySegment
      }

-- A single regimen inside a preset, which can have its own image categories set
-- separately.
let PresetRegimen
    : Type
    = { regimenId : Text, categories : Optional (List Text) }

-- A list of regimens that can be selected through the custom session screen and
-- used with the quickstart feature. The activities in each regimen are
-- concatenated together to form one continuous drawing session.
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

-- The set of available activities.
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

-- The set of regimens available for use.
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
      , { id = "free_draw_15"
        , humanName = "Free Draw (15 minutes)"
        , defaultCategories = [] : List Text
        , activities =
          [ { activityId = "free_draw"
            , durationMinutes = 15
            , unboundedDuration = True
            }
          ]
        }
      ]

-- The set of presets available for use. They will appear in the custom session
-- screen. They can also be used for automatic scheduling using preset orders
-- (see below).
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
      , { id = "free_draw_15"
        , humanName = "Free Draw (15 minutes)"
        , regimens =
          [ { regimenId = "free_draw_15", categories = None (List Text) } ]
        }
      ]

-- List of presets to cycle through for the block-based learning feature. After
-- a quickstart session for learning/free drawing is finished, the next preset
-- in the list will be selected for the next quickstart session of that type,
-- wrapping around. The time spent on learning and free drawing will be kept
-- track of to stay close to a 50% balance.
let PresetOrder
    : Type
    = { tutorial : List Text, free : List Text }

-- Presets that will be cycled through when more tutorial time is needed.
let presetOrderTutorial
    : List Text
    = [ "fig_dab2_3", "test" ]

-- Presets that will be cycled through when more free draw time is needed.
let presetOrderFree
    : List Text
    = [ "free_draw_15" ]

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
