module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.App
import Html.Events
import Mouse
import Dom
import Task
import Json.Decode


main : Program Never
main =
    Html.App.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Label =
    { pos : Mouse.Position, text : String }


type alias Model =
    { diagramUrl : String
    , message : String
    , nextDiagram : String
    , lastClick : Mouse.Position
    , nextLabel : String
    , labels : List Label
    }


init : ( Model, Cmd Msg )
init =
    { diagramUrl = "elmview.png"
    , message = "Hello World"
    , nextDiagram = ""
    , lastClick = { x = 40, y = 50 }
    , nextLabel = ""
    , labels = []
    }
        ! []



-- SUBSCRIPTIONS


subscriptions model =
    Mouse.clicks Click



-- UPDATE


type Msg
    = Noop
    | NewDiagram
    | NextDiagram String
    | Click Mouse.Position
    | NextLabel String
    | DomError Dom.Error
    | FocusSuccess ()
    | SaveLabel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewDiagram ->
            { model
                | message = "New Diagram Time"
                , diagramUrl = model.nextDiagram
            }
                ! []

        Noop ->
            model ! []

        NextDiagram string ->
            { model | nextDiagram = string } ! []

        Click lastClick ->
            { model | lastClick = lastClick } ! [ requestFocus "nextLabel" ]

        NextLabel string ->
            { model | nextLabel = string } ! []

        DomError (Dom.NotFound notFound) ->
            { model | message = "Error! Field not found: " ++ notFound } ! []

        FocusSuccess _ ->
            model ! []

        SaveLabel ->
            { model
                | labels =
                    { pos = model.lastClick
                    , text = model.nextLabel
                    }
                        :: model.labels
            }
                ! []



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.main' []
            [ Html.canvas
                [ style [ ( "backgroundImage", "url(" ++ model.diagramUrl ++ ")" ) ]
                ]
                []
            , lastClickPoint model
            , labelsView model
            ]
        , Html.aside []
            [ Html.text model.message
            , Html.hr [] []
            , nextDiagramInput model
            , Html.button [ Html.Events.onClick NewDiagram ] [ Html.text "New Diagram" ]
            ]
        ]


lastClickPoint model =
    Html.div
        [ style
            [ ( "position", "absolute" )
            , ( "left", (toString model.lastClick.x) ++ "px" )
            , ( "top", (toString model.lastClick.y) ++ "px" )
            ]
        ]
        [ Html.img
            [ Html.Attributes.id "lastClickPoint"
            , Html.Attributes.src "x.png"
            ]
            []
        , nextLabelInput model
        ]


labelsView model =
    let
        labelElement label =
            Html.label
                []
                [ Html.text label.text ]
    in
        Html.div []
            (List.map labelElement model.labels)


nextDiagramInput : Model -> Html Msg
nextDiagramInput model =
    Html.input
        [ Html.Attributes.id "nextDiagram"
        , Html.Events.onInput NextDiagram
        , Html.Attributes.value model.nextDiagram
        ]
        []


nextLabelInput : Model -> Html Msg
nextLabelInput model =
    Html.input
        [ Html.Attributes.id "nextLabel"
        , Html.Events.onInput NextLabel
        , onEnter SaveLabel
        , Html.Attributes.value model.nextLabel
        ]
        []


requestFocus field_id =
    Task.perform DomError FocusSuccess (Dom.focus field_id)


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    let
        tagger code =
            if code == 13 then
                msg
            else
                Noop
    in
        Html.Events.on "keydown" (Json.Decode.map tagger Html.Events.keyCode)
