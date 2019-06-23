module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, h1, img, input, pre, text)
import Html.Attributes exposing (placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Http



---- MODEL ----


type RequestState
    = Failure
    | Loading
    | Success String


type alias Model =
    { counter : Int
    , content : String
    , request : RequestState
    }


init : ( Model, Cmd Msg )
init =
    ( { counter = 0, content = "", request = Loading }
    , Http.get
        { url = "http://localhost:3000/hello"
        , expect = Http.expectString GotText

        --, header = [ ( "Access-Control-Allow-Origin", "true" ) ]
        }
    )



---- UPDATE ----


type Msg
    = Increment
    | Decrement
    | Change String
    | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Decrement ->
            ( { model | counter = model.counter - 1 }, Cmd.none )

        Change newContent ->
            ( { model | content = newContent }, Cmd.none )

        GotText result ->
            case result of
                Ok fullText ->
                    ( { model | request = Success fullText }, Cmd.none )

                Err _ ->
                    ( { model | request = Failure }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Welcome to Away Day!" ]
        , div [] [ text (String.fromInt model.counter) ]
        , div [] [ text model.content ]
        , button [ onClick Increment ] [ text "+" ]
        , button [ onClick Decrement ] [ text "-" ]
        , input
            [ placeholder "Please type your name here..."
            , value model.content
            , onInput Change
            ]
            []
        , viewText model
        ]


viewText : Model -> Html Msg
viewText model =
    case model.request of
        Loading ->
            text "Loading..."

        Failure ->
            text "I was not able to load"

        Success fullText ->
            pre [] [ text fullText ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
