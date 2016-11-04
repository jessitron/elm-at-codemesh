module Main exposing (main)

import Html exposing (Html)
import Html.Attributes exposing (style)


main : Html Never
main =
    Html.div []
        [ Html.main' []
            [ Html.canvas
                [ style [ ( "backgroundImage", "url(elmview.png)" ) ]
                ]
                []
            ]
        , Html.aside [] [ Html.text "Hello World" ]
        ]
