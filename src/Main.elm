module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.App
import Html.Events


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
    | NewDiagram


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewDiagram ->
            { model | message = "New Diagram Time" }

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
        , Html.aside []
            [ Html.text model.message
            , Html.hr [] []
            , Html.button [ Html.Events.onClick NewDiagram ] [ Html.text "New Diagram" ]
            ]
        ]