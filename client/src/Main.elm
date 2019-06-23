module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, h1, img, input, pre, text)
import Html.Attributes exposing (placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, float, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias Pokémon =
    { id : Int
    , name : String
    , description : String
    , imageSrc : String
    , types : List String
    , price : Float
    }



-- HTTP


getPokémon : Cmd Msg
getPokémon =
    Http.get
        { url = "http://localhost:3000/articles"
        , expect = Http.expectJson GotPokémon decoder
        }


decoder : Decoder (List Pokémon)
decoder =
    list pokémonDecoder


pokémonDecoder : Decoder Pokémon
pokémonDecoder =
    Decode.succeed Pokémon
        |> required "id" int
        |> required "name" string
        |> required "description" string
        |> required "imageSrc" string
        |> required "types" (list string)
        |> required "price" float



---- MODEL ----


type RequestState
    = Failure
    | Loading
    | Success (List Pokémon)


type alias Model =
    { counter : Int
    , content : String
    , request : RequestState
    }


init : ( Model, Cmd Msg )
init =
    ( { counter = 0, content = "", request = Loading }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = Increment
    | Decrement
    | Change String
    | GotPokémon (Result Http.Error (List Pokémon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Decrement ->
            ( { model | counter = model.counter - 1 }, Cmd.none )

        Change newContent ->
            ( { model | content = newContent }, Cmd.none )

        GotPokémon result ->
            case result of
                Ok allPokemon ->
                    ( { model | request = Success allPokemon }, Cmd.none )

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
        , viewPokémon model
        ]


viewPokémon : Model -> Html Msg
viewPokémon model =
    case model.request of
        Loading ->
            text "Loading..."

        Failure ->
            text "I was not able to load any pocket creatures"

        Success allPokémon ->
            text "something"



-- List.map (\ element -> text element)
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
