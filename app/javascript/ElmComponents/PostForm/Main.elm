module ElmComponents.PostForm.Main exposing (..)

import Browser
import Html exposing (Html, p, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string)
import Json.Encode as Encode



-- MODEL


type alias Model =
    String



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( "Hello", Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    p [ onClick FetchUrl ] [ text "Hello" ]



-- MESSAGE


type Msg
    = FetchUrl
    | GotUrl (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchUrl ->
            ( model, requestUrls )

        GotUrl result ->
            ( model, Cmd.none )


requestUrls : Cmd Msg
requestUrls =
    Http.post
        { url = "/rails/active_storage/direct_uploads"
        , body = Http.jsonBody urlRequest
        , expect = Http.expectJson GotUrl urlDecoder
        }


urlDecoder : Decoder String
urlDecoder =
    field "direct_upload" (field "url" string)


urlRequest : Encode.Value
urlRequest =
    Encode.object
        [ ( "blob"
          , Encode.object
                [ ( "filename", Encode.string "test.jpg" )
                , ( "content_type", Encode.string "image/jpeg" )
                , ( "byte_size", Encode.string "1024" )
                , ( "checksum", Encode.string "123" )
                ]
          )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
