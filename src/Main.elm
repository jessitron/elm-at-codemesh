module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.App


main : Program Never
main =
    Html.App.beginnerProgram
        { model = model
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { diagramUrl : String, message : String }


model : Model
model =
    { diagramUrl = "elmview.png"
    , message = "Hello World"
    }



-- UPDATE


type Msg
    = Noop


update : Msg -> Model -> Model
update msg model =
    case msg of
        Noop ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.main' []
            [ Html.canvas
                [ style [ ( "backgroundImage", "url(" ++ model.diagramUrl ++ ")" ) ]
                ]
                []
            ]
        , Html.aside [] [ Html.text model.message ]
        ]
