module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.App
import Html.Events
import Mouse


main : Program Never
main =
    Html.App.program
        {  init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { diagramUrl : String, message : String, nextDiagram : String , lastClick : Mouse.Position }


init : ( Model, Cmd Msg )
init =
    { diagramUrl = "elmview.png"
    , message = "Hello World"
    , nextDiagram = "" , lastClick = { x = 40, y = 50 }
    } ! []



-- UPDATE


type Msg
    = Noop
    | NewDiagram
    | NextDiagram String
    | Click Mouse.Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewDiagram ->
            { model
                | message = "New Diagram Time"
                , diagramUrl = model.nextDiagram
            } ! []

        Noop ->
            model ! []

        NextDiagram string ->
            { model | nextDiagram = string } ! []

        Click lastClick ->
            { model | lastClick = lastClick } ! []



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
            , nextDiagramInput model
            , Html.button [ Html.Events.onClick NewDiagram ] [ Html.text "New Diagram" ]
            ]
        ]


nextDiagramInput : Model -> Html Msg
nextDiagramInput model =
    Html.input
        [ Html.Attributes.id "nextDiagram"
        , Html.Events.onInput NextDiagram
        , Html.Attributes.value model.nextDiagram
        ]
        []




-- SUBSCRIPTIONS


subscriptions model =
    Mouse.clicks Click