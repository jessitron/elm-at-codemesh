module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.App
import Html.Events
import Mouse
import Dom
import Task
import Json.Decode
import Window


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
    , lastClick : Maybe Mouse.Position
    , nextLabel : String
    , labels : List Label , windowSize : Window.Size
    }


init : ( Model, Cmd Msg )
init =
    { diagramUrl = "elmprogram.png"
    , message = "Hello World"
    , nextDiagram = ""
    , lastClick = Nothing
    , nextLabel = ""
    , labels = [] , windowSize = { width = 1, height = 1 }
    }
        ! [ Task.perform SomeError WindowSize Window.size ]



-- SUBSCRIPTIONS


subscriptions model =
    Sub.batch [ Window.resizes WindowSize, Mouse.clicks Click ]



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
    | WindowSize Window.Size
    | SomeError String


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
            { model | lastClick = Just lastClick } ! [ requestFocus "nextLabel" ]

        NextLabel string ->
            { model | nextLabel = string } ! []

        DomError (Dom.NotFound notFound) ->
            { model | message = "Error! Field not found: " ++ notFound } ! []

        FocusSuccess _ ->
            model ! []

        SaveLabel ->
            (saveLabel model) ! []

        WindowSize windowSize ->
            { model | windowSize = windowSize } ! []

        SomeError err ->
            model ! []



-- VIEW


saveLabel model =
    case model.lastClick of
        Nothing ->
            { model | message = "That was not expected!" }

        Just lastClick ->
            { model
                | labels =
                    { pos = lastClick
                    , text = model.nextLabel
                    }
                        :: model.labels
                , nextLabel = ""
                , lastClick = Nothing
            }


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


beAt { x, y } =
    [ ( "position", "absolute" )
    , ( "left", (toString x) ++ "px" )
    , ( "top", (toString y) ++ "px" )
    ]


lastClickPoint model =
    case model.lastClick of
        Nothing ->
            Html.div [] []

        Just lastClick ->
            Html.div
                [ style (beAt lastClick)
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
                [ style (beAt label.pos) ]
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